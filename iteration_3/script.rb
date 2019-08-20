API_KEY = ENV['LEGANTO_API_KEY']

require 'faraday'
require 'json'
require 'ostruct'
require 'pickup'

API_BASE_URL = 'https://api-eu.hosted.exlibrisgroup.com/almaws/v1'

default_weights = {
    "ESS": 50,
    "REC": 25,
    "OPT": 10
}

multiple_courses = [
    {course_id: '82433203710001221', reading_list_id: '82433203850001221'},
    {course_id: '82432817500001221', reading_list_id: '82432817970001221'},
    {course_id: '82433594010001221', reading_list_id: '82433594170001221'}
]

weighted_citations = []

multiple_courses.each do |course|

    puts "Retrieivng reading list #{course[:reading_list]}"

    response = Faraday.get "#{API_BASE_URL}/courses/#{course[:course_id]}/reading-lists/#{course[:reading_list_id]}", {view: 'full'}, {accept: 'application/json', authorization: "apikey #{API_KEY}"}

    citations = JSON.parse(response.body)["citations"]["citation"]

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

        title_fields = ["title", "article_title"]

        title = "Unknown"

        title_fields.each do |field|
            data = c["metadata"][field]

            unless (data.nil? || data.empty?)

                title = data

                break

            end

        end

        mms_id = c["metadata"]["mms_id"]

        key = "MMS_#{mms_id}"

        if (mms_id.nil? || mms_id.empty?)

            key = "ID_#{c["id"]}"

        end

        weighted_citations.push OpenStruct.new(key: key, name: title, weight: weight)

    end
    
    puts "Finished reading list #{course[:reading_list]}"

end

key_func = Proc.new{ |item| item.key }
weight_func = Proc.new{ |item| item.weight }
name_func = Proc.new { |item| item.name}

pickup = Pickup.new(weighted_citations, key_func: key_func, weight_func: weight_func, uniq: true)

puts pickup.pick(1, key_func: name_func)