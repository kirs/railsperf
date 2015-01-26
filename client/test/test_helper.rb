# test_helper.rb
ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'
require 'pry'

require File.expand_path '../../server.rb', __FILE__

require File.expand_path '../../../test/support/db_cleaner.rb', __FILE__
