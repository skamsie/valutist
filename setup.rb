require "bundler/setup"
Bundler.require(:default, ENV["APP_ENV"] || :development)

require_relative "valutist"
