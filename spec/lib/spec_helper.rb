require 'rspec'
require 'date'
require 'bundler'

Bundler.require

def html_fixture(name)
  path = File.join( File.dirname(File.expand_path(__FILE__)), '..', 'fixtures', "#{name}.html" )
  File.read( path )
end
