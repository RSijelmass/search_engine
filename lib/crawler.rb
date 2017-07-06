require 'open-uri'
require 'nokogiri'
require 'csv'
require_relative 'seed_data'

class Crawler
	attr_reader :seeds 

	def initialize(seeds)
		@seeds = seeds
	end

	def fetch_data
		create_csv_file
		i = 0
		@seeds.each do |seed|
			i += 1
			checked_seed = check_url_or_file(seed)

			id = i 
			urls = fetch_urls(checked_seed)
			keywords = fetch_metadata('keywords', checked_seed)
			description = fetch_metadata('description',checked_seed)
			headers = fetch_headers(checked_seed)
			text = fetch_paragraphs(checked_seed)
						
			seed_data = SeedData.new(id, seed, urls, keywords, description, headers, text)
			seed_data.store_in_csv
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
		full_text = ""
		seed_paragraph_nodeset = seed.xpath('//p')
		seed_paragraph_nodeset.each do |node|
			raw_text = node.text.delete('^A-Za-z ')
			raw_text.gsub!(/[\n,\t]/, " ") if raw_text.include?('\n')
			full_text += "#{raw_text} "
		end
		return full_text.split.join(" ")
	end

	def fetch_headers(seed)
		headers = []
		headers_tags = (1..6).map { |num| "h#{num}"}
		headers_tags.each do |header_tag|
			headers << get_header_from_tag(seed, header_tag)
		end
		return headers.flatten
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

	def get_header_from_tag(seed , header_tag)
		headers_from_one_tag = []
		headers_from_nodeset = seed.xpath("//#{header_tag}")
		headers_from_nodeset.each do |node|
			headers_from_one_tag << node.text
		end
		return headers_from_one_tag
	end

	def create_csv_file
		File.open('seeddata.csv', 'w') { |f| f.truncate(0) } #empties csv file before writing in 
		CSV.open('seeddata.csv', 'a+', col_sep: "|", quote_char: "|") do |row|
			row << ["id", "seed", "urls", "keywords", "description", "headers", "text"]
		end
	end
end

crawler = Crawler.new(['http://www.bbc.co.uk', 'http://www.makersacademy.com'])
crawler.fetch_data
