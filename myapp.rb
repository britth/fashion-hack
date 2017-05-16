require 'sinatra'
require 'httparty'
require 'json'
require_relative 'narrative.rb'


set :static, true
set :public_folder, "static"
set :views, "views"

get '/' do
    erb :main_form
end

post '/' do
  API_BASE = "http://api.shopstyle.com/api/v2/products/histogram?pid=#{ENV["SHOPSENSE_KEY"]}&filters=Retailer&fts="

    search = params[:search] || "Nothing"
    response = HTTParty.get(API_BASE + "#{search}")
    response_count = response["retailerHistogram"].count
    id = response["retailerHistogram"].sort_by{|x| -x["count"]}.first["id"] || 0
    selection = HTTParty.get("http://api.shopstyle.com/api/v2/products?pid=#{ENV["SHOPSENSE_KEY"]}&fts=#{search}&fl=r#{id}&offset=0&limit=10")

    all_items = HTTParty.get("http://api.shopstyle.com/api/v2/products?pid=#{ENV["SHOPSENSE_KEY"]}&cat=#{selection["metadata"]["category"]["id"]}&fl=r#{id}&offset=0")
    image = selection["products"].compact.first["image"]["sizes"]["IPhone"]["url"]
    images = selection["products"].compact.map{|x| x["image"]["sizes"]["IPhone"]["url"]}
    description = selection["products"].compact.first["description"]
    color = if all_items["products"].compact.first["colors"].count == 0
              ''
            else
              all_items["products"].compact.first["colors"].first["name"]
            end
    colors = all_items["products"].map{|x| x["colors"].compact}.select{|x| x.count > 0}.map{|x| x.first["name"]}.select{|x| x != color}.uniq{|x| x}
    retailer_name = response["retailerHistogram"].compact.sort_by{|x| -x["count"]}.first["name"]
    prices = all_items["products"].compact.map{|x| x["price"]}.sort_by{|x| x}
    brands = all_items["products"].compact.map{|x| x["brand"]}.compact.map{|x| x["name"]}.uniq{|x| x}
    sizes = all_items["products"].compact.map{|x| x["sizes"]}.select{|x| x.count > 0}.map{|x| x.first["name"]}.uniq{|x| x}.sort_by{|x| x}

    data = {
        type: selection["metadata"]["category"]["id"],
        short_name: selection["metadata"]["category"]["fullName"],
        size: sizes,
        classic_colors: color,
        additional_colors: colors.join(', '),
        price_low: prices.first,
        price_high: prices.last,
        pick_up_in_store: 0,
        online_only: 0,
        top_brands: brands.join(', '),
        four_plus_rating: 0,
        occasion_shoes_skirts: '',
        pattern_jackets: '',
        fit_jeans: '',
        style_shorts_dresses: '',
        silhouette_underwear: '',
        sleeves_button_down_blazers: '',
        neckline_sweaters: ''
      }
    narrative = Narrative.new().get_content(data)

    erb :index, :locals => {'search' => search, 'id' => id, 'image' => image, 'images' => images, 'description' => description, 'narrative' => narrative, 'retailer_name' => retailer_name}

end
