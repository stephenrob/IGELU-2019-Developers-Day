API_KEY = ENV['LEGANTO_API_KEY']

require 'faraday'
require 'json'
require 'ostruct'
require 'pickup'

API_BASE_URL = 'https://api-eu.hosted.exlibrisgroup.com/almaws/v1'
COURSE_ID = '82433203710001221'
READING_LIST_ID = '82433203850001221'

default_weights = {
  "ESS": 50,
  "REC": 25,
  "OPT": 10
}

response = Faraday.get "#{API_BASE_URL}/courses/#{COURSE_ID}/reading-lists/#{READING_LIST_ID}", {view: 'full'}, {accept: 'application/json', authorization: "apikey #{API_KEY}"}

citations = JSON.parse(response.body)["citations"]["citation"]

weighted_citations = []

citations.each do |c|

    tags = c["citation_tags"]["citation_tag"]
    set_tags = []
    weight = 0

    if tags.nil? || tags.empty?

        weight = 5

    else

        tags.each do |t|

            value = t["value"]["value"]

            weight += default_weights[value.to_sym] if default_weights.keys.include? value.to_sym
    
        end

    end

    weighted_citations.push OpenStruct.new(key: c["metadata"]["mms_id"], name: c["metadata"]["title"], weight: weight)

end


key_func = Proc.new{ |item| item.key }
weight_func = Proc.new{ |item| item.weight }
name_func = Proc.new { |item| item.name}

pickup = Pickup.new(weighted_citations, key_func: key_func, weight_func: weight_func, uniq: true)

puts pickup.pick(3, key_func: name_func)