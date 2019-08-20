API_KEY = ENV['LEGANTO_API_KEY']

require 'faraday'
require 'json'

API_BASE_URL = 'https://api-eu.hosted.exlibrisgroup.com/almaws/v1'
COURSE_ID = '82433203710001221'
READING_LIST_ID = '82433203850001221'

response = Faraday.get "#{API_BASE_URL}/courses/#{COURSE_ID}/reading-lists/#{READING_LIST_ID}", {view: 'full'}, {accept: 'application/json', authorization: "apikey #{API_KEY}"}

citations = JSON.parse(response.body)["citations"]["citation"]

citation_titles = citations.map { |c| c["metadata"]["title"] }

puts citation_titles.sample