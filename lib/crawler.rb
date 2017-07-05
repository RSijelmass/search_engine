require 'open-uri'
require 'nokogiri'

class Crawler
	attr_reader :seeds, :urls, :keywords, :paragraph, :description

	def initialize(seeds)
		@seeds = seeds
	end

	def fetch_data
		@seeds.each do |seed|
			checked_seed = check_url_or_file(seed)
			@urls = fetch_urls(checked_seed)
			@keywords = fetch_metadata('keywords', checked_seed)
			@description = fetch_metadata('description',checked_seed)
			@paragraph = fetch_paragraphs(checked_seed)
		end
	end

	def fetch_urls(seed)
		urls = []
		seed_urls_nodeset = seed.xpath('//a')
		seed_urls_nodeset.each do |node|
			urls << node.first[1] if node.first[1].include?('http://')
		end
		return urls
	end

	def fetch_metadata(attribute, seed)
		meta_from_nodeset = seed.xpath('//meta')
		get_from_nodeset(attribute, meta_from_nodeset)
	end

		def fetch_paragraphs(seed)
		paragraphs = []
		seed_paragraph_nodeset = seed.xpath('//p')
		seed_paragraph_nodeset.each do |node|
			# p node.text
			paragraphs << node.text
		end
		return paragraphs.join("")
	end

	private

	def check_url_or_file(seed)
		if(seed.include? ('file://'))
			seed.slice!('file://')
			File.open(seed) { |f| Nokogiri::HTML(f)}
		else
			Nokogiri::HTML(open(seed))
		end
	end

		def get_from_nodeset(attribute, nodeset)
		nodeset.each do |node|
			next unless node.attributes['name']
			output = node.attributes['content'].value
		 	output = output.split(/\s*,\s*/) if attribute == 'keywords'
			return output if node.attributes['name'].value == attribute
		end
	end
end
