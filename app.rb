require_relative "models/exchange_rate"
require "sinatra/base"
require "sinatra/param"
require "http"
require "dotenv"
require "rack/contrib"
require "sinatra/reloader"
require "set"

Dotenv.load

class App < Sinatra::Base
  FIXER_API_KEY = ENV["FIXER_API_KEY"]
  FIXER_API_URL = "http://data.fixer.io/api/"
  UPDATE_INTERVAL = 10800 # seconds

  use Rack::PostBodyContentTypeParser
  helpers Sinatra::Param

  configure :development do
    register Sinatra::Reloader
  end

  before do
    content_type :json
    get_latest_exchange_rates if should_update_exchange_rates?
  end

  get "/latest" do
    ExchangeRate.last.as_json.reject{ |k| k == "id" }.to_json
  end

  post "/convert" do
    rates = ExchangeRate.last.as_json.compact

    param(
      :from, String, transform: :upcase, required: true,
      in: rates.keys.reject do |i|
        ["id", "created_at", "base_currency"].include?(i)
      end,
      message: "Currency not supported"
    )
    param(
      :to, Array,
      transform: lambda { |i| i.map{ |j| j.gsub(" ", "").upcase } },
      required: true
    )
    param :amount, Integer, min: 1, max: 10_000_000, required: true

    unless params["to"].to_set.subset?(rates.keys.to_set)
      halt(
        400,
        {
          "message": "Currency not supported",
          "errors": {
            "to": "At least one currency is not supported"
          }
        }.to_json
      )
    end

    base_to_from = rates[rates["base_currency"]] / rates[params["from"]]
    result = {}

    params["to"].each do |currency|
      entry = (base_to_from * rates[currency] * params["amount"]).round(2)
      result[currency] = entry
    end

    {
      from: params["from"],
      to: params["to"],
      amount: params["amount"],
      result: result,
      updated_at: rates["created_at"]
    }.to_json
  end

  private

  def should_update_exchange_rates?
    return true if ExchangeRate.count == 0
    Time.now.getutc - ExchangeRate.last["created_at"] > UPDATE_INTERVAL
  end

  def get_latest_exchange_rates
    response = HTTP.get(
      "#{FIXER_API_URL}/latest",
      params: { access_key: FIXER_API_KEY }
    )
    body = JSON.load(response.body)
    rates = body["rates"].select do |k, v|
      ExchangeRate.column_names.include?(k.upcase)
    end

    rates_to_insert = Hash[rates.map{|k, v| [k.upcase, v]}]
    rates_to_insert.store(:base_currency, body["base"])

    ExchangeRate.create(rates_to_insert) if response.code == 200
    response.code
  end
end
