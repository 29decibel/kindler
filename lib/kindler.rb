require "kindler/version"
require "readability"
require "open-uri"

module Kindler
	class Book
		attr_accessor :urls
		TMP_DIR = 'kindler_generated_tmp'

		def initialize(options={})
			@urls = options[:urls] || {}
			@title = options[:title] || ''
			@author = options[:author] || ''
			@doc_infos = {}
			# init doc infos by url
			@urls.each {|url| @doc_infos[url]= {} }
		end

		def add_url(url)
			return if @doc_infos[url]
			@urls << url
			@doc_infos[url] = {}
		end

		def generate(title)
			# make tmp directory
			# remove previous
			FileUtils.rm_rf TMP_DIR if File.exist?(TMP_DIR)
			FileUtils.mkdir_p TMP_DIR unless File.exist?(TMP_DIR)
			generate_html
			generate_toc
			generate_opf
			generate_ncx
			kindlegen
		end

		private

		# make sure kindlegen is installed
		# you can use "sudo brew install " to install it
		def kindlegen
			puts 'begin generate mobi'
			system("kindlegen #{TMP_DIR}/#{@title}.opf")
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
			File.open(file_path('contents'),'w') do |f|
				f.puts contents
			end
		end

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
						<text>My_Title</text>
					</docTitle>
					<docAuthor>
						<text>Benthien, George</text>
					</docAuthor>
					<navMap>
				NCX
			contents << <<-NAV
			<navPoint id="navpoint-1" playOrder="1">
				<navLabel><text>Table Of Contents</text></navLabel>
				<content src="contents.html"/>
			</navPoint>
			NAV
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
			File.open("#{TMP_DIR}/nav-contents.ncx",'w') { |f| f.puts contents }
		end

		def generate_opf
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
							<dc:date>#{Time.now.to_date}/dc:date>
							<dc:description>Kindler generated book</dc:description>
						</dc-metadata>
						<x-metadata>
							<output content-type="application/x-mobipocket-subscription-magazine" encoding="utf-8"/>
						</x-metadata>
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
			contents << "<spine toc='nav-contents'>"
			contents << "<itemref idref='contents'/>"
			files_count = 1
			@doc_infos.each do |url,infos|
				contents << "<itemref idref='#{files_count.to_s.rjust(3,'0')}'/>"
				files_count += 1
			end
			contents << "</spine><guide><reference href='contents.html' type='toc' title='Table of Contents'/></guide></package>"
			File.open("#{TMP_DIR}/#{@title}.opf",'w') {|f| f.puts contents}
		end

		def generate_html
			@doc_infos.each do |url,infos|
				article = readable_article(url)
				infos[:content] = html_wrap(article.title,article.content)
				infos[:title] = article.title
			end
			# make html files
			files_count = 1
			@doc_infos.each do |url,infos|
				File.open(file_path(files_count.to_s.rjust(3,'0')),'w') do |f|
					f.puts infos[:content]
				end
				files_count += 1
			end
		end

		def file_path(file_name)
			"#{TMP_DIR}/#{file_name}.html"
		end

		def html_wrap(title,content)
			result = ''
			result << '<html><head>'
			result << "<meta content='text/html; charset=utf-8' http-equiv='Content-Type'/>"
			result << '</head><body>'
			result << "<h1>#{title}</h1>"
			result << content
			result << '</body></html>'
		end

		def readable_article(url)
			puts "begin fetch url : #{url}"
			source = open(url).read
			Readability::Document.new(source)
		end

	end
end
