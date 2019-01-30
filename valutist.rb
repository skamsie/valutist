require "set"
require "sinatra/activerecord"
require "sinatra/custom_logger"
require "logger"
require_relative "models/exchange_rate"

class Valutist < Sinatra::Base
  FIXER_API_KEY = ENV["FIXER_API_KEY"]
  FIXER_API_URL = ENV["FIXER_API_URL"]
  UPDATE_INTERVAL = 1080 # seconds
  ROUND = 4

  use Rack::PostBodyContentTypeParser
  helpers Sinatra::Param
  enable :logging

  configure :development do
    register Sinatra::Reloader
  end

  before do
    content_type :json
    latest_exchange_rates if should_update_exchange_rates?
  end

  get "/latest" do
    ExchangeRate.last.as_json
      .reject { |k| k == "id" }
      .transform_values do |v|
        if v.is_a?(Numeric)
          v.round(ROUND)
        elsif v.methods.include?(:strftime)
          v.to_time.iso8601
        else
          v
        end
      end
      .to_json
  end

  post "/convert" do
    rates = ExchangeRate.last.as_json.compact

    param(
      :from, String,
      transform: :upcase,
      required: true,
      in: rates.keys.reject do |i|
        %w[id created_at base_currency].include?(i)
      end,
      message: "Currency not supported"
    )
    param(
      :to, Array,
      transform: ->(i) { i.map { |j| j.delete(" ").upcase } },
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
      entry = (base_to_from * rates[currency] * params["amount"]).round(ROUND)
      result[currency] = entry
    end

    {
      from: params["from"],
      to: params["to"],
      amount: params["amount"],
      result: result,
      updated_at: rates["created_at"].to_time.iso8601
    }.to_json
  end

  private

  def should_update_exchange_rates?
    return true if ExchangeRate.count.zero?

    Time.now.getutc - ExchangeRate.last["created_at"] > UPDATE_INTERVAL
  end

  def latest_exchange_rates
    response = HTTP.get(
      "#{FIXER_API_URL}/latest",
      params: { access_key: FIXER_API_KEY }
    )
    body = JSON.parse(response.body)

    unless response.code.to_s.start_with?("2") && body["success"]
      request.logger.warn(body["error"])
      return
    end

    rates = body["rates"].select do |k, _|
      ExchangeRate.column_names.include?(k.upcase)
    end

    rates_to_insert = Hash[rates.map { |k, v| [k.upcase, v] }]
    rates_to_insert.store(:base_currency, body["base"])

    ExchangeRate.create(rates_to_insert)
  end
end
