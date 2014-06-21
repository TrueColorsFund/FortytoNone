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
  city = params[:city].gsub(" ", "+")
  state = params[:state].gsub(" ", "+")

  page = Nokogiri::HTML(open("http://www.refugerestrooms.org/restrooms?lat=40.7127837&long=-74.00594130000002&page=2&search=#{city}%2C+#{state}%2C+United+States&utf8=%E2%9C%93"))
  jace =[]
  page.css(".itemName").each do |item|
    jace << item.text
  end
  jace.to_json
end
get "/index" do
  "<script src='http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js'></script>"
end
