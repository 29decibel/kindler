#encoding: utf-8
require 'rubygems'
require "open-uri"
require "nokogiri"
require "cgi"
require "erb"
require "shellwords"
require "fileutils"
# require 'mini_magick'
require_relative 'kindler/railtie' if defined?(Rails)
require_relative "kindler/version"

module Kindler
  class Book
    class KindlerError < StandardError;end

    attr_accessor :title,:author,:pages,:pages_by_section,:local_images,:mobi_type,:style,:cover_image

    TMP_DIR_PREFIX = '__km_'
    DEFAULT_SECTION = "All Pages"
    PAGE_ATTRIBUTES = %w(wrap title author content section url)

    # availabel options
    # @param options [Hash]
    # @option title [String] book title
    # @option output_dir [String] directory want to generate
    # @option debug [Boolean] whether puts debug infos
    # @option keep_image [Boolean] whether keep images, default to true
    def initialize(options={})
      @output_dir = options[:output_dir] || ''
      @keep_image = options[:keep_image] || true
      @debug = options[:debug]
      @title = options[:title] || ''
      @author = options[:author] || 'unknown'
      @mobi_type = options[:mobi_type] || :simple
      @cover = options[:cover] || ""
      @silent = options[:silent]
      @pages = []
      @local_images = []
      @pages_by_section = {}
      @style = options[:style] || ''
      raise KindlerError.new("must provide the book title ") unless title
    end

    def add_page(options={})
      raise KindlerError.new('must provide title when add page') unless options[:title]
      page = options.reject{|k,v| PAGE_ATTRIBUTES.include?(k)}
      page[:wrap] ||= true
      page[:section] ||= DEFAULT_SECTION
      page[:count] = pages.count + 1
      page[:file_name] = "#{page[:count].to_s.rjust(3,'0')}.html"
      page[:author] = '' unless page[:author]
      # escape special chars
      page[:title] = CGI::escapeHTML(page[:title])
      page[:title] = title if(page[:title] == "")
      page[:author] = CGI::escapeHTML(page[:author])
      pages << page
      debug pages
    end

    def add_article(options={})
      add_page(options)
    end

    def generate
      make_generated_dirs
      localize_images if @keep_image
      prepare_conver_img
      # reorder count index
      if magzine?
        sectionize_pages
      end
      generate_toc
      generate_opf
      generate_ncx
      write_to_disk
      kindlegen
    end

    def sectionize_pages
      self.pages.each do |page|
        pages_by_section[page[:section]] ||= []
        pages_by_section[page[:section]] << page
      end
      self.pages = pages_by_section.values.flatten
      self.pages.each_with_index do |page,index|
        page[:count] = index + 1
        page[:file_name] = "#{page[:count].to_s.rjust(3,'0')}.html"
      end
    end

    # check mobi file is generated already
    def generated?
      File.exist? book_path
    end

    def book_path
      "#{tmp_dir}/#{title}.mobi"
    end

    private
    # make sure kindlegen is installed
    # you can use "sudo brew install " to install it
    def kindlegen
      debug 'begin generate mobi'
      cmd = "kindleGen #{Shellwords.escape(tmp_dir)}/#{Shellwords.escape(title)}.opf #{@silent ? "> /dev/null" : ""}"
      system(cmd)
    end

    # generate contents.html
    def generate_toc
      template = ERB.new(open(File.join(File.dirname(__FILE__),"templates/book.toc.erb")).read)
      @toc = template.result(binding)
    end

    # generate ncx , which is navigation
    def generate_ncx
      play_order = 1
      template = ERB.new(open(File.join(File.dirname(__FILE__),"templates/book.ncx.erb")).read)
      @ncx = template.result(binding)
    end

    def magzine?
      @mobi_type == :magzine
    end

    # generate the opf, manifest of book,including all articles and images and css
    def generate_opf
      template = ERB.new(open(File.join(File.dirname(__FILE__),"templates/book.opf.erb")).read)
      @opf = template.result(binding)
    end

    def meta_info
      {}
    end

    def get_image_extname(image_data,url)
      ext = File.extname('url')
      if ext == ''
        ext = case image_data.content_type
        when /jpeg/i
          '.jpg'
        when /png/i
          '.png'
        when /gif/i
          '.gif'
        else
          '.jpg'
        end
      end
      ext
    end

    def localize_images
      images_count = 1
      pages.each do |page|
        article = Nokogiri::HTML(page[:content])
        article.css('img').each do |img|
          begin
            # get remote address
            image_remote_address = img.attr('src')
            unless image_remote_address.start_with?('http')
              image_remote_address = URI.join(page[:url], image_remote_address).to_s
            end
            # get local address
            image_data = open(image_remote_address)
            image_extname = get_image_extname(image_data,image_remote_address)
            image_local_address = File.join(tmp_dir,"#{images_count}#{image_extname}")
            # download images
            debug "begin fetch image #{image_remote_address}"
            debug "save to #{image_local_address}"
            #`curl #{image_remote_address} > #{image_local_address}`
            File.open(image_local_address,'wb') do |f|
              f.write image_data.read
            end
            debug 'Image saved'
            # replace local url address
            img.attributes['src'].value = "#{image_local_address}"
            page[:content] = article.inner_html
            # add to manifest
            local_images << "#{image_local_address}"
            images_count += 1
          rescue Exception => e
            debug "got error when fetch and save image: #{e}"
          end
        end
      end
    end

    # html file path
    def file_path(file_name)
      "#{tmp_dir}/#{file_name}"
    end

    # wrap readable contents with in html format
    def html_wrap(page)
      template = ERB.new(open(File.join(File.dirname(__FILE__),"templates/page.html.erb")).read)
      template.result(binding)
    end

    # the dir path to generated files
    def tmp_dir
      File.expand_path (@output_dir == '' ? "#{TMP_DIR_PREFIX}#{title}" : @output_dir)
    end

    # 1. using imagemagick to crop a image to 600*800
    # 2. set the image url to something
    def prepare_conver_img
      if @local_images.length > 0
        image_file = @local_images.first
        @cover_image = "#{File.dirname(image_file)}/cover-image.jpg"
        cmd = "convert #{Shellwords.escape(image_file)} -compose over -background white -flatten -resize '566x738' -alpha off #{Shellwords.escape(@cover_image)}"
        `#{cmd}` rescue ''
      end
    end

    # create dirs of generated files
    def make_generated_dirs
      FileUtils.rm_rf tmp_dir if File.exist?(tmp_dir)
      FileUtils.mkdir_p tmp_dir unless File.exist?(tmp_dir)
    end

    def write_to_disk
      File.open("#{tmp_dir}/nav-contents.ncx",'wb') { |f| f.write @ncx }
      File.open(file_path('contents.html'),'wb') {|f| f.write @toc }
      File.open("#{tmp_dir}/#{title}.opf",'wb') {|f| f.write @opf}
      # make html files
      files_count = 1
      pages.each do |page|
        File.open(file_path(page[:file_name]),'wb') do |f|
          content_to_write = page[:wrap] ? html_wrap(page) : page[:content]
          debug "here is the page #{page[:title]} need to write"
          debug content_to_write
          f.write content_to_write
        end
        files_count += 1
      end

    end

    def debug(str)
      return unless @debug
      Rails.logger.info(str) if defined?(Rails)
      puts str
    end

  end
end
