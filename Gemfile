# frozen_string_literal: true

source "https://rubygems.org"

ruby "~> 2.5.0"

gem "activerecord"
gem "dotenv"
gem "http"
gem "json"
gem "pg"
gem "pry"
gem "puma"
gem "rake"
gem "sinatra"
gem "sinatra-activerecord"
gem "sinatra-param"
gem "rack-contrib"

group :development do
  gem "sinatra-reloader"
end

group :development, :test do
  gem "faker"
  gem "rspec"
  gem "rubocop"
  gem "webmock", require: false
  gem "timecop"
  gem "pry-byebug"
end
