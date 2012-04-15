#encoding: utf-8
require 'rubygems'
require "open-uri"
require "nokogiri"
require "cgi"
# require 'mini_magick'
require_relative 'kindler/railtie' if defined?(Rails)
require_relative "kindler/version"

module Kindler
  class Book
    class KindlerError < StandardError;end

    attr_accessor :title,:author,:pages,:pages_by_section,:local_images,:mobi_type

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
      @mobi_type = options[:mobi_type] || :magzine
      @pages = []
      @local_images = []
      @pages_by_section = {}
      raise KindlerError.new("must provide the book title ") unless title
    end

    def add_page(options={})
      raise KindlerError.new('must provide title when add page') unless options[:title]
      page = options.reject{|k,v| PAGE_ATTRIBUTES.include?(k)}
      page[:wrap] ||= true
      page[:section] ||= DEFAULT_SECTION
      page[:count] = pages.count + 1
      page[:file_name] = "#{page[:count].to_s.rjust(3,'0')}.html"
      page[:author] = 'unknown' if (page[:author]==nil or page[:author]=='')
      # escape special chars
      page[:title] = CGI::escapeHTML(page[:title])
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
      "#{tmp_dir}/#{valid_title}.mobi"
    end

    private
    # make sure kindlegen is installed
    # you can use "sudo brew install " to install it
    def kindlegen
      debug 'begin generate mobi'
      system("kindlegen #{tmp_dir}/#{valid_title}.opf ")
    end

    # generate contents.html
    def generate_toc
      contents = <<-CODE
        <html>
          <head>
            <meta content="text/html; charset=utf-8" http-equiv="Content-Type"/>
            <title>Table of Contents</title>
          </head>
          <body>
            <h1>Contents</h1>
            <h4>Main section</h4>
            <ul>
      CODE
      files_count = 1
      pages.each do |page|
        contents << "<li><a href='#{files_count.to_s.rjust(3,'0')}.html'>#{page[:title]}</a></li>"
        files_count += 1
      end
      # append footer
      contents << "</ul></body></html>"

      @toc = contents
    end

    # generate ncx , which is navigation
    def generate_ncx
      contents = <<-NCX
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE ncx PUBLIC "-//NISO//DTD ncx 2005-1//EN" "http://www.daisy.org/z3986/2005/ncx-2005-1.dtd">
        <ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1" xml:lang="en-US">
          <head>
            <meta name="dtb:uid" content="#{title}"/>
            <meta name="dtb:depth" content="1"/>
            <meta name="dtb:totalPageCount" content="0"/>
            <meta name="dtb:maxPageNumber" content="0"/>
          </head>
          <docTitle>
            <text>#{title}</text>
          </docTitle>
          <docAuthor>
            <text>#{author}</text>
          </docAuthor>
          <navMap>
      NCX
      contents << (magzine? ? magzine_ncx : flat_ncx)
      contents << "</navMap></ncx>"
      @ncx = contents
    end

    def flat_ncx
      contents = ''
      files_count = 2
      pages.each do |page|
        nav_point = <<-NAV
          <navPoint id="navpoint-#{files_count}" playOrder="#{files_count}">
            <navLabel><text>#{page[:title]}</text></navLabel>
            <content src="#{(files_count-1).to_s.rjust(3,'0')}.html"/>
          </navPoint>
        NAV
        contents << nav_point
        files_count += 1
      end
      contents
    end

    def magzine_ncx
      contents = ''

      contents << <<-MAG
      <navPoint playOrder="0" class="periodical" id="periodical">
        <navLabel>
          <text>Table of Contents</text>
        </navLabel>
        <content src="contents.html"/>

      MAG

      play_order = 1
      @pages_by_section.each do |section,pages|
        next if pages.count==0
        # add section header
        contents << <<-SECHEADER
          <navPoint playOrder="#{play_order}" class="section" id="#{section}">
                 <navLabel>
                   <text>#{section}</text>
                 </navLabel>
                 <content src="#{pages.first[:file_name]}"/>
        SECHEADER

        play_order += 1
        # add pages nav
        pages.each do |page|
          contents << <<-PAGE
           <navPoint playOrder="#{play_order}" class="article" id="item-#{page[:count].to_s.rjust(3,'0')}">
             <navLabel>
               <text>#{page[:title]}</text>
             </navLabel>
             <content src="#{page[:file_name]}"/>
             <mbp:meta name="description">#{page[:title]}</mbp:meta>
             <mbp:meta name="author">#{page[:author]}</mbp:meta>
           </navPoint>
          PAGE
          play_order += 1
        end
        # add section footer
        contents << "</navPoint>"
      end
      contents << "</navPoint>"
    end

    def magzine_meta
      <<-META
        <x-metadata>
          <output content-type="application/x-mobipocket-subscription-magazine" encoding="utf-8"/>
        </x-metadata>
      META
    end

    def magzine?
      @mobi_type == :magzine
    end

    # generate the opf, manifest of book,including all articles and images and css
    def generate_opf
      contents = <<-HTML
        <?xml version='1.0' encoding='utf-8'?>
        <package xmlns="http://www.idpf.org/2007/opf" version="2.0" unique-identifier="#{title}">
          <metadata>
            <dc-metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
              <dc:title>#{title}</dc:title>
              <dc:language>en-gb</dc:language>
              <meta content="cover-image" name="cover"/>
              <dc:creator>Kindler- 29decibel</dc:creator>
              <dc:publisher>Kindler- 29decibel</dc:publisher>
              <dc:subject>News</dc:subject>
              <dc:identifier id="#{title}">#{title}</dc:identifier>
              <dc:date>#{Time.now.to_date}</dc:date>
              <dc:description>Kindler generated book</dc:description>
            </dc-metadata>
            #{magzine? ? magzine_meta : ''}
          </metadata>
          <manifest>
      HTML
      files_count = 1
      pages.each do |page|
        doc_id = files_count.to_s.rjust(3,'0')
        contents << "<item href='#{doc_id}.html' media-type='application/xhtml+xml' id='#{doc_id}'/>"
        files_count += 1
      end
      contents << "<item href='contents.html' media-type='application/xhtml+xml' id='contents'/>"
      contents << "<item href='nav-contents.ncx' media-type='application/x-dtbncx+xml' id='nav-contents'/>"
      contents << "</manifest>"
      contents << "<spine toc='nav-contents'>"
      contents << "<itemref idref='contents'/>"
      files_count = 1
      pages.each do |page|
        contents << "<itemref idref='#{files_count.to_s.rjust(3,'0')}'/>"
        files_count += 1
      end
      contents << "</spine><guide><reference href='contents.html' type='toc' title='Table of Contents'/></guide></package>"
      @opf = contents
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
              image_remote_address = "http://#{URI(page[:url]).host}#{image_remote_address}"
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
    def html_wrap(title,content)
      result = ''
      result << '<html><head>'
      result << "<meta content='text/html; charset=utf-8' http-equiv='Content-Type'/>"
      result << '</head><body>'
      result << "<h3>#{title}</h3>"
      result << content
      result << '</body></html>'
    end

    # the dir path to generated files
    def tmp_dir
      File.expand_path (@output_dir == '' ? "#{TMP_DIR_PREFIX}#{valid_title}" : @output_dir)
    end

    def valid_title
      @v_title ||= @title.gsub(' ','_')
    end

    # create dirs of generated files
    def make_generated_dirs
      FileUtils.rm_rf tmp_dir if File.exist?(tmp_dir)
      FileUtils.mkdir_p tmp_dir unless File.exist?(tmp_dir)
    end

    def write_to_disk
      File.open("#{tmp_dir}/nav-contents.ncx",'wb') { |f| f.write @ncx }
      File.open(file_path('contents.html'),'wb') {|f| f.write @toc }
      File.open("#{tmp_dir}/#{valid_title}.opf",'wb') {|f| f.write @opf}
      # make html files
      files_count = 1
      pages.each do |page|
        File.open(file_path(page[:file_name]),'wb') do |f|
          content_to_write = page[:wrap] ? html_wrap(page[:title],page[:content]) : page[:content]
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
