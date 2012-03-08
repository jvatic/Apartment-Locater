require 'rspec'
require 'date'
require 'bundler'

Bundler.require

require File.join( File.dirname( File.expand_path(__FILE__) ), '..', 'database' )

DataMapper.setup(:default,
  :adapter  => 'mongo',
  :database => "apartment-find_test",
)
