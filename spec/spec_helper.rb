ENV["APP_ENV"] = "test"
ENV["FIXER_API_URL"] = "http://data.fixer.io/api"

require_relative "../setup"
require "rack/test"
require "rspec"
require "webmock/rspec"

module RSpecMixin
  include Rack::Test::Methods

  def app
    described_class
  end

  def last_response_body
    JSON.parse(last_response.body)
  end
end

RSpec.configure do |config|
  WebMock.disable_net_connect!(allow_localhost: true)

  config.include FactoryBot::Syntax::Methods
  config.include RSpecMixin

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
end

def supported_currencies
  ExchangeRate.column_names.select { |x| /[[:upper:]]/.match(x) }
end

def stub_fixer_request_latest(success = true, rates = nil)
  uri = "#{ENV['FIXER_API_URL']}/latest"
  default_rates = Hash[
    supported_currencies.map do |x|
      [x, (x == "EUR" ? 1 : rand(0.5..100)).round(5)]
    end
  ]
  stub_request(:get, uri)
    .with(query: { access_key: nil })
    .and_return(
      status: 200,
      body: {
        "success": success,
        "timestamp": 1548854046,
        "base": "EUR",
        "date": "2019-01-30",
        "rates": rates || default_rates
      }.to_json
    )
end
