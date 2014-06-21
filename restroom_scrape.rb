require "nokogiri"
require "open-uri"
require "json"
require "pry"
require "sinatra"
require "sinatra/reloader"
# puts "What state are you in?"
# state = gets.chomp
# puts "What city are you in?"
# city = gets.chomp

get "/" do
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
    item_json = {
      name: item.search(".itemName").text,
      location: item.search(".itemStreet").text,
      rating: item.search(".itemRating").text,
      accessible: !item["class"].include?("not_accessible"),
      unisex: !item["class"].include?("not_unisex"),
      paid: true,
      welcoming: false
    }
    jace[:bathrooms] << item_json
  end
  jace.to_json
end
get "/index" do
  "<script src='http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js'></script>"
end
