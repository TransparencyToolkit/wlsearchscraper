require 'nokogiri'
require 'open-uri'

class WLSearchScraper
  def initialize(searchterms)
    @searchterms = searchterms
    @resultlist = Array.new
  end
  
  # Returns array of document IDs matching search terms
  def scrape
    @searchterms.gsub!(" ", "+")
    url = "https://search.wikileaks.org/advanced?q=" + @searchterms + "&exclude_words=&words_title_only=&words_content_only=&publication_type[]=3"
    html = Nokogiri::HTML(open(url))

    html.css("h4").each do |h|
      href = h.css("a")[0]["href"]
      split = href.split("/")
      cable = split[split.length-1].split("_a.html")
      @resultlist.push(cable[0])
    end
    
    return @resultlist
  end
end
