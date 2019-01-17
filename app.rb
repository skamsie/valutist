require_relative 'models/exchange_rate'
require 'sinatra'
require 'http'
require 'dotenv'

Dotenv.load

class App < Sinatra::Base
  FIXER_API_KEY = ENV["FIXER_API_KEY"]
  FIXER_API_URL = "http://data.fixer.io/api/"
  UPDATE_INTERVAL = 10800 # seconds

  get '/latest' do
    get_latest_exchange_rates if should_update_exchange_rates?

    content_type :json
    ExchangeRate.last.as_json.reject{ |k| k == "id" }.to_json
  end

  private

  def should_update_exchange_rates?
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
