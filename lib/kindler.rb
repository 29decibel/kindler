require "kindler/version"
require "readability"

module Kindler
	class Book
		attr_accessor :urls

		def initialize(*urls)
			@urls = urls
			@doc_infos = {}
		end

		def add_url(url)
			@urls << url
		end

		def generate(title)
			@urls.each do |url|
				title,contents = generate_html(url)
				@doc_infos[url] = {:title=>title,:contents=>contents}
			end
			generate_toc
			# using kingen to generate final mobi file
		end

		private
		def generate_toc
			
		end

		def generate_html
			
		end

	end
end
