ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'

class ActiveSupport::TestCase
  def html_fixture(name)
    path = File.join(Rails.root, 'test', 'fixtures', "#{name}.html")

    File.read(path)
  end

  def strategy_sample(num, klass)
    @samples ||= {}
    unless @samples[num]
      name = "#{ klass.name.split('::').last.tableize }_#{num}"
      @samples[num] = klass.new("#{name}.html")
      @samples[num].doc = Nokogiri::HTML( html_fixture(name) )
    end
    @samples[num]
  end
end
