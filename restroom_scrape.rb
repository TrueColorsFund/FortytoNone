require "nokogiri"
require "open-uri"
require "json"
require "sinatra"
require "sinatra/reloader"
# puts "What state are you in?"
# state = gets.chomp
# puts "What city are you in?"
# city = gets.chomp
require 'sinatra/cross_origin'

configure do
  enable :cross_origin
end
set :allow_origin, :any
set :allow_methods, [:get, :post, :options]
set :allow_credentials, true
set :max_age, "1728000"
set :expose_headers, ['Content-Type']
get "/search_bathrooms.json" do
  content_type :json
  if params[:lat]
    lat = params[:lat]
    long = params[:long]
  else
    lat = 40.7127837
    long = -74.00594130000002
  end
  url = "http://www.refugerestrooms.org/restrooms?search=current+location&lat=#{lat}&long=#{long}&page=1"
  page = Nokogiri::HTML(open(url))
  jace = {latitude: lat, longitude: long, bathrooms: []}
  page.css(".listItem").each do |item|
    given_location = item.search(".itemStreet").text
    loc_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{given_location.gsub(" ", "+")}&key=AIzaSyBCuzH2kGD5AyZwTVtEz2v0evKk8pr3IV8"
    loc = Nokogiri::HTML(open(loc_url))
    if loc["results"]
      lat_long = loc["results"]["geometry"]["location"]
    else
      lat_long = {"lat" => nil, "lng" => nil}
    end
    item_json = {
      name: item.search(".itemName").text,
      location: given_location,
      rating: item.search(".itemRating").text,
      accessible: !item["class"].include?("not_accessible"),
      unisex: !item["class"].include?("not_unisex"),
      paid: true,
      welcoming: false,
      latitude: lat_long["lat"],
      longitude: lat_long["lng"]
    }
    jace[:bathrooms] << item_json
  end
  jace.to_json
end
