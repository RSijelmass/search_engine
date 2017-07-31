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
		@seeds.each_with_index do |seed, id|
			checked_seed = check_url_or_file(seed)
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
		seed_urls_nodeset = seed.xpath('//a')
		urls = seed_urls_nodeset.inject("") do |urls, node|
			node.first[1].include?('http') ? (urls + node.first[1] + " ") : urls
		end
		return urls.strip
	end

	def fetch_metadata(attribute, seed)
		meta_from_nodeset = seed.xpath('//meta')
		get_from_nodeset(attribute, meta_from_nodeset)
	end

		def fetch_paragraphs(seed)
		seed_paragraph_nodeset = seed.xpath('//p')
		full_text = seed_paragraph_nodeset.inject("") do |text, node|
			raw_text = node.text.delete('^A-Za-z ')
			raw_text.gsub!(/[\n,\t]/, " ") if raw_text.include?('\n')
			text + "#{raw_text} "
		end
		return full_text.split.join(" ")
	end

	def fetch_headers(seed)
		headers_tags = (1..6).map { |num| "h#{num}"}
		headers = headers_tags.inject("") do |header_text, header_tag|
			tag_header = get_header_from_tag(seed, header_tag)
			tag_header ? (header_text + tag_header + " ") : (header_text)
		end
		headers.gsub!(/[^\w ]/, "")
		return headers.strip
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
			output.gsub!(",", "")
			return output if node.attributes['name'].value == attribute
		end
	end

	def get_header_from_tag(seed , header_tag)
		headers_from_nodeset = seed.xpath("//#{header_tag}")
		headers_from_tag = headers_from_nodeset.inject("") do |text_tag, node|
			text_tag + node.text + " "
		end
		return headers_from_tag.strip if headers_from_tag.strip.length > 0
	end

	def create_csv_file
		File.open('seeddata.csv', 'w') { |f| f.truncate(0) } #empties csv file before writing in 
		CSV.open('seeddata.csv', 'a+', col_sep: "|", quote_char: "|") do |row|
			row << ["id", "seed", "urls", "keywords", "description", "headers", "text"]
		end
	end
end
