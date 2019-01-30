# frozen_string_literal: true

source "https://rubygems.org"

ruby "~> 2.5.0"

gem "activerecord"
gem "http"
gem "json"
gem "pg"
gem "pry"
gem "puma"
gem "rake"
gem "sinatra", require: "sinatra/base"
gem "sinatra-activerecord", require: "sinatra/activerecord"
gem "sinatra-param", require: "sinatra/param"
gem "rack-contrib", require: "rack/contrib"

group :development do
  gem "sinatra-reloader", require: "sinatra/reloader"
  gem "dotenv", require: "dotenv/load"
end

group :test do
  gem "database_cleaner"
end

group :development, :test do
  gem "rack-test", require: "rack/test"
  gem "faker"
  gem "rspec"
  gem "rubocop"
  gem "webmock"
  gem "timecop"
  gem "pry-byebug"
end
