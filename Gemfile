# frozen_string_literal: true

source "https://rubygems.org"

ruby "~> 2.5.0"

gem "pg"
gem "dotenv"
gem "activerecord"
gem "sinatra"
gem "sinatra-activerecord"
gem "rake"
gem "puma"
gem "http"
gem "pry"
gem "json"

group :development do
  gem "rerun"
end

group :development, :test do
  gem "faker"
  gem "rspec"
  gem "rubocop"
  gem "webmock", require: false
  gem "timecop"
  gem "pry-byebug"
end
