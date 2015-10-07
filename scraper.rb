#encoding: utf-8
require 'scraperwiki'
require 'nokogiri'
require 'json'

# Read in a page
url = "https://docs.google.com/spreadsheets/d/1QkkIRF-3Qrz-aRIxERbGbB7YHWz2-t4ix-7TEcuBNfE/pubhtml?gid=607896942&single=true"
page = Nokogiri::HTML(open(url), nil, 'utf-8')
rows = page.xpath('//table[@class="waffle"]/tbody/tr')

# Find something on the page using css selectors
content = []
rows.collect do |r|
  content << r.xpath('td').map { |td| td.text.strip }
end

# Builds records
content.shift
content.each do |row|

  tags = []
  row[3].gsub(', ',',').split(',').each do |tag|
    tags << tag.strip
  end

  record = {
    "date" => row[0],
    "title" => row[1],
    "summary" => row[2],
    "tags" => tags,
    "source" => row[4],
    "img" => row[5],
    "highlighted" => row[6],
    "last_update" => Date.today.to_s
  }

  # Save if the record doesn't exist
  if ((ScraperWiki.select("* from data where `source`='#{record['source']}'").empty?) rescue true)
    record['tags'] = JSON.dump(record['tags'])
    ScraperWiki.save_sqlite(["source"], record)
    puts "Adds new record from " + record['source']
  else
    puts "Skipping already saved record from " + record['source']
  end
end

# # An arbitrary query against the database
# ScraperWiki.select("* from data where 'name'='peter'")

# You don't have to do things with the Mechanize or ScraperWiki libraries.
# You can use whatever gems you want: https://morph.io/documentation/ruby
# All that matters is that your final data is written to an SQLite database
# called "data.sqlite" in the current working directory which has at least a table
# called "data".
