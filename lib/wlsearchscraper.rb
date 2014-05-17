require 'nokogiri'
require 'open-uri'
require 'json'

class WLSearchScraper
  def initialize(searchterms)
    @searchterms = searchterms
    @resultlist = Array.new
  end
  
  # Returns array of document URLs matching search terms
  def scrape
    @searchterms.gsub!(" ", "+")
    url = "https://search.wikileaks.org/advanced?q=" + @searchterms + "&exclude_words=&words_title_only=&words_content_only=&publication_type[]=3"
    html = Nokogiri::HTML(open(url))

    html.css("h4").each do |h|
      href = h.css("a")[0]["href"]
      @resultlist.push(cableParser(href))
    end
    
    return JSON.pretty_generate(@resultlist)
  end

  def cableParser(url)
    cablehash = Hash.new
    html = Nokogiri::HTML(open(url))
    
    # Go through and get all the metadata and content
    html.css("td").each do |t|
      a = t.css("a")
      if !(a.empty?) && (a[0]["title"] == "Date")
        cablehash[:date] = t.css("div[2]").text
      elsif !(a.empty?) && (a[0]["title"] == "Canonical ID")
        cablehash[:id] = t.css("div[2]").text
      elsif !(a.empty?) && (a[0]["title"] == "Original Classification")
        cablehash[:original_classification] = t.css("div[2]").text
      elsif !(a.empty?) && (a[0]["title"] == "Current Classification")
        cablehash[:current_classification] = t.css("div[2]").text
      elsif !(a.empty?) && (a[0]["title"] == "Handling Restrictions")
        cablehash[:handling_restrictions] = t.css("div[2]").text
      elsif !(a.empty?) && (a[0]["title"] == "Character Count")
        cablehash[:character_count] = t.css("div[2]").text
      elsif !(a.empty?) && (a[0]["title"] == "Executive Order")
        cablehash[:executive_order] = t.css("div[2]").text
      elsif !(a.empty?) && (a[0]["title"] == "Locator")
        cablehash[:locator] = t.css("div[2]").text
      elsif !(a.empty?) && (a[0]["title"] == "TAGS")
        cablehash[:tags] = t.css("div[2]").text
      elsif !(a.empty?) && (a[0]["title"] == "Concepts")
        cablehash[:concepts] = t.css("div[2]").text
      elsif !(a.empty?) && (a[0]["title"] == "Enclosure")
        cablehash[:enclosure] = t.css("div[2]").text
      elsif !(a.empty?) && (a[0]["title"] == "Type")
        cablehash[:type] = t.css("div[2]").text
      elsif !(a.empty?) && (a[0]["title"] == "Office Origin")
        cablehash[:office_origin] = t.css("div[2]").text
      elsif !(a.empty?) && (a[0]["title"] == "Office Action")
        cablehash[:office_action] = t.css("div[2]").text
      elsif !(a.empty?) && (a[0]["title"] == "Archive Status")
        cablehash[:archive_status] = t.css("div[2]").text
      elsif !(a.empty?) && (a[0]["title"] == "From")
        cablehash[:from] = t.css("div[2]").text
      elsif !(a.empty?) && (a[0]["title"] == "Markings")
        cablehash[:markings] = t.css("div[2]").text
      elsif !(a.empty?) && (a[0]["title"] == "To")
        to = t.css("div[2]").text
        splitto = to.split(" | ")
        splitarray = Array.new
        splitto.each do |s|
          splitarray.push(s.strip)
        end
        cablehash[:to] = splitarray
      elsif !(a.empty?) && (a[0]["title"] == "Linked documents or other documents with the same ID")
        cablehash[:linked_docs] = t.css("div[2]").text
      end
    end

    # Get cable content
    contentcount = 0
    html.css("div").each do |d|
     if d["class"] == "text-content"
       contentcount += 1
       if contentcount == 2
         cablehash[:content] = d.text
       end
     end
    end
    
    return cablehash
  end
end
