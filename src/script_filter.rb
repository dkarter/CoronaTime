# frozen_string_literal: true

require 'erb'
require 'json'
require 'net/http'
require 'uri'

query = ARGV[0].to_s.strip
state = query != '' ? query : ENV['state']

ICONS = {
  'Confirmed' => '☣️',
  'Deaths' => '☠️',
  'Recovered' => '✅'
}.freeze

where = ERB::Util.url_encode("Country_Region='#{state}' OR Province_State='#{state}'")
uri = URI("https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/ncov_cases/FeatureServer/1/query?f=json&where=#{where}&outFields=Confirmed,Recovered,Deaths")
resp = Net::HTTP.get(uri)
json_resp = JSON.parse(resp)

dig = (((json_resp['features'] || []).first || {})['attributes'] || [])
title = { title: "Cases in #{state}:", valid: false }
stats = dig.map do |(k, v)|
  { title: "#{ICONS[k]} #{k}: #{v}", icon: { path: ' ' }, valid: false }
end

items =
  if !stats.empty?
    stats.prepend(title)
  else
    [{ title: 'no results found', valid: false }]
  end

puts({ items: items }.to_json)
