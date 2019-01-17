require_relative 'models/exchange_rate'
require 'sinatra'
require 'http'
require 'dotenv'

Dotenv.load

class App < Sinatra::Base
  FIXER_API_KEY = ENV["FIXER_API_KEY"]
  FIXER_API_URL = "http://data.fixer.io/api/"

  get '/' do
    get_latest_exchange_rates
  end

  private

  def get_latest_exchange_rates
    response = HTTP.get(
      "#{FIXER_API_URL}/latest",
      params: { access_key: FIXER_API_KEY }
    )
    body = JSON.load(response.body)
    rates = body["rates"].select do |k, v|
      ExchangeRate.column_names.include?(k.downcase)
    end

    rates_to_insert = Hash[rates.map{|k, v| [k.downcase, v]}]

    ExchangeRate.create(rates_to_insert)
  end
end
