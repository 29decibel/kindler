#encoding: utf-8
require 'rubygems'
require "readability"
require "open-uri"
# require 'mini_magick'
require_relative 'kindler/railtie' if defined?(Rails)
require_relative "kindler/version"

module Kindler
	class Book
		class KindlerError < StandardError;end
		attr_accessor :urls,:title,:author,:doc_infos
		TMP_DIR = 'kindler_generated_mobi'

		# availabel options
		# @param options [Hash]
		# @option urls [Array] urls to generate
		# @option title [String] book title
		# @option output_dir [String] directory want to generate
		# @option debug [Boolean] whether puts debug infos
		# @option keep_image [Boolean] whether keep images, default to true
		def initialize(options={})
			@urls = options[:urls] || {}
			@title = options[:title] || ''
			@output_dir = options[:output_dir] || './'
			@keep_image = options[:keep_image] || true
			@debug = options[:debug]
			raise KindlerError.new("urls option could not be empty") if @urls.empty?
			@author = options[:author] || ''
			@images = []
			@doc_infos = {}
			# init doc infos by url
			@urls.each {|url| @doc_infos[url]= {} }
		end

		# add url to book
		# @param url [String] url to add to book
		# @param options [Hash]
		# @option section [Symbol] indicate which section the url belongs to,if not empty the book will be generated with magzine style
		def add_url(url,options={})
			return if @doc_infos[url]
			@urls << url
			@doc_infos[url] = {}
		end

		# generate books by given urls
		def generate(title='')
			make_generated_dirs
			# generate
			generate_html
			localize_images
			generate_toc
			generate_opf
			generate_ncx
			write_to_disk
			kindlegen
			# clear
		end

		# check mobi file is generated already
		def mobi_generated?
			File.exist? "#{tmp_dir}/#{@title}.mobi"
		end

		private
		# make sure kindlegen is installed
		# you can use "sudo brew install " to install it
		def kindlegen
			debug 'begin generate mobi'
			system("kindlegen #{tmp_dir}/#{@title}.opf ")
		end

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
			@doc_infos.each do |url,infos|
				contents << "<li><a href='#{files_count.to_s.rjust(3,'0')}.html'>#{infos[:title]}</a></li>"
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
						<meta name="dtb:uid" content="#{@title}"/>
						<meta name="dtb:depth" content="1"/>
						<meta name="dtb:totalPageCount" content="0"/>
						<meta name="dtb:maxPageNumber" content="0"/>
					</head>
					<docTitle>
						<text>#{@title}</text>
					</docTitle>
					<docAuthor>
						<text>#{@author}</text>
					</docAuthor>
					<navMap>
			NCX
			files_count = 2
			@doc_infos.each do |url,infos|
				nav_point = <<-NAV
					<navPoint id="navpoint-#{files_count}" playOrder="#{files_count}">
						<navLabel><text>#{infos[:title]}</text></navLabel>
						<content src="#{(files_count-1).to_s.rjust(3,'0')}.html"/>
					</navPoint>
				NAV
				contents << nav_point
				files_count += 1
			end
			contents << "</navMap></ncx>"
			@ncx = contents
		end

		# generate the opf, manifest of book,including all articles and images and css
		def generate_opf
			# mark mobi as magzine format
			# <x-metadata>
			#	 <output content-type="application/x-mobipocket-subscription-magazine" encoding="utf-8"/>
			# </x-metadata>
			contents = <<-HTML
				<?xml version='1.0' encoding='utf-8'?>
				<package xmlns="http://www.idpf.org/2007/opf" version="2.0" unique-identifier="#{@title}">
					<metadata>
						<dc-metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
							<dc:title>#{@title}</dc:title>
							<dc:language>en-gb</dc:language>
							<meta content="cover-image" name="cover"/>
							<dc:creator>Kindler- 29decibel</dc:creator>
							<dc:publisher>Kindler- 29decibel</dc:publisher>
							<dc:subject>News</dc:subject>
							<dc:identifier id="#{@title}">#{@title}</dc:identifier>
							<dc:date>#{Time.now.to_date}/dc:date>
							<dc:description>Kindler generated book</dc:description>
						</dc-metadata>
					</metadata>
					<manifest>
			HTML
			files_count = 1
			@doc_infos.each do |url,infos|
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
			@doc_infos.each do |url,infos|
				contents << "<itemref idref='#{files_count.to_s.rjust(3,'0')}'/>"
				files_count += 1
			end
			contents << "</spine><guide><reference href='contents.html' type='toc' title='Table of Contents'/></guide></package>"
			@opf = contents
		end

		# generate every url to article in readable format
		def generate_html
			@doc_infos.each do |url,infos|
				article = readable_article(url)
				if article
					# puts article.images
					infos[:content] = html_wrap(article.title,article.content)
					infos[:title] = article.title
				end
			end
			@doc_infos = @doc_infos.reject{|url,infos| infos[:content]==nil or infos[:title]==nil }
		end

		def localize_images
			images_count = 1
			@doc_infos.each do |url,infos|
				article = Nokogiri::HTML(infos[:content])
				article.css('img').each do |img|
					begin
						image_remote_address = img.attr('src')
						unless image_remote_address.start_with?('http')
							image_remote_address = "http://#{URI(url).host}#{image_remote_address}"
						end
						image_local_address = File.join(tmp_dir,"#{images_count}#{File.extname(image_remote_address)}")
						# download images
						debug "begin fetch image #{image_remote_address}"
						debug "save to #{image_local_address}"
						File.open(image_local_address,'wb') do |f|
							f.write open(image_remote_address).read
						end
						debug 'Image saved'
						# replace local url address
						img.attributes['src'].value = "#{images_count}#{File.extname(image_remote_address)}"
						infos[:content] = article.inner_html
						# add to manifest
						@images << "#{images_count}#{File.extname(image_remote_address)}"
						images_count += 1 
					rescue Exception => e
						debug "got error when fetch and save image: #{e}"
					end
				end
			end
		end

		# html file path
		def file_path(file_name)
			"#{tmp_dir}/#{file_name}.html"
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

		# get readable document by url, using ruby-readability here
		def readable_article(url)
			debug "begin fetch url : #{url}"
			begin
				source = open(url).read
			rescue Exception => e
				debug "got some erros,#{e}"
				return nil
			end
			if @keep_image
				Readability::Document.new(source,:tags=>%w(div p img a),:attributes => %w[src href],:remove_empty_nodes => false)
			else
				Readability::Document.new(source)
			end
		end

		# the dir path to generated files
		def tmp_dir
			File.join @output_dir,"#{TMP_DIR}_#{@title.gsub(' ','_')}"
		end

		# create dirs of generated files
		def make_generated_dirs
			FileUtils.rm_rf tmp_dir if File.exist?(tmp_dir)
			FileUtils.mkdir_p tmp_dir unless File.exist?(tmp_dir)
		end

		def write_to_disk
			File.open("#{tmp_dir}/nav-contents.ncx",'wb') { |f| f.write @ncx }
			File.open(file_path('contents'),'wb') {|f| f.write @toc }
			File.open("#{tmp_dir}/#{@title}.opf",'wb') {|f| f.write @opf}
			# make html files
			files_count = 1
			@doc_infos.each do |url,infos|
				File.open(file_path(files_count.to_s.rjust(3,'0')),'wb') do |f|
					f.write infos[:content]
				end
				files_count += 1
			end

		end

		# exist to clear tmp files such as ncx,opf or html other than mobi file
		# keep them right now
		def clear_tmp_dirs
			
		end

		def debug(str)
			return unless @debug
			Rails.logger.info(str) if defined?(Rails)
			puts str
		end

	end
end
