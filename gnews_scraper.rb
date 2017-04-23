require 'pp'
require 'pry'
require 'httparty'
require 'nokogiri'
require 'pp'
require 'json'
require 'sinatra'


class GoogleNews
  def initialize
    @base_uri = 'https://news.google.com/'
  end

  def news
    data = []
    scraped = Nokogiri::HTML(HTTParty.get(@base_uri), &:noblanks)
    articles = scraped.css ".blended-wrapper"

    articles.each do |a|
      title = a.css(".titletext").first.text
      href = a.css(".article").first['href']
      original_source = a.css(".al-attribution-source")[0].text
      brief = a.css(".esc-lead-snippet-wrapper")[0].text
      ago = a.css(".al-attribution-timestamp")[0].text

      serialized = {
        'title' => title,
        'href' => href,
        'source' => original_source,
        'truncated_text' => brief,
        'time_stamp' => parseDT(ago).strftime
      }
      data << serialized
    end
    # the function returns an array of objects to use in api
    return data
  end
end

def parseDT ts
  sp = ts.split
  if sp[1] == 'minutes'
    DateTime.now - (sp[0].to_i / 1440.0)
  else
    # hours
    DateTime.now - (sp[0].to_i / 24.0)
  end
end



get '/' do
  g = GoogleNews.new
  {
    :timestamp => DateTime.now,
    :data => g.news
  }.to_json
end
