require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'sinatra/jsonp'

get '/' do
end

get '/:term' do |term|
  doc = Nokogiri::HTML(open("http://lingvo.mail.ru/?lang_id=1033&translate=%D0%9D%D0%B0%D0%B9%D1%82%D0%B8&text=#{URI.escape(term)}&st=search"))  

  json = {}

  result = doc.css('.lol-card.first')
  json[:html] = result.to_s

  entry = result.css('.Bold')
  json[:entry] = { :text => entry.text, :html => entry.to_s }

  type = result.at_css('.P1')
  if type.css('.comment').any?
    json[:type] = { :text => type.text, :html => type.to_s }
    type.remove
  end

  examples = result.css('.P1.optional')
  json[:examples] = []
  examples.each do |example|
    # if example.text == "••"
    #   next
    # end
    json[:examples] << { :text => example.text, :html => example.to_s }
  end
  examples.remove

  json[:definitions] = []
  result.css('.P1').each do |p1|
    definition = { :text => p1.text, :html => p1.to_s }
    definition[:examples] = []

    sibling = p1.next_sibling
    while sibling.attr('class') =~ /P2/
      example = { :text => sibling.text, :html => sibling.to_s }
      definition[:examples] << example
      sibling = sibling.next_sibling
    end

    json[:definitions] << definition
  end

  JSONP json
    
end
