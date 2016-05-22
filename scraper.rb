require 'scraperwiki'
require 'open-uri'
require 'nokogiri'
require 'pry'
require 'fileutils'
require 'uri'

FileUtils.rm_rf 'data.sqlite'

class Scraper
  def run
    base_url = "http://www.partilovnemnda.no";

    front = fetch(URI.join(base_url, '/Vedtak/'))
    year_links = front.css('ul.nav a').select { |e| e.text.strip =~ /^\d{4}$/}

    year_links.each do |year_link|      
      url = URI.join(base_url, year_link.attr('href'));
      year = year_link.text.strip

      puts url

      page = fetch(url)

      entries = page.css('.post a').select { |e| e.attr('href') =~ /\.pdf$/ }

      entries.each do |e|
        ScraperWiki.save_sqlite [:year, :title, :url], {
          year: year, 
          title: e.attr('title') || e.text.strip.gsub(/\s+/, ' '), 
          url: File.join(base_url, e.attr('href'))
        }        
      end

    end
  end

  private

  def fetch(url)
    Nokogiri::HTML.parse(open(url).read)
  end
end

# ScraperWiki.save_sqlite [:party, :organization, :contributor_name], data


Scraper.new.run