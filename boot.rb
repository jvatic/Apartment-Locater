require 'bundler'

Bundler.require

Geocoder::Configuration.lookup  = :google
Geocoder::Configuration.timeout = 10

require "active_support/core_ext/module"

class Hash
  def recursive_symbolize_keys
    keys.each do |key|
      new_key = (key.to_sym rescue key) || key
      self[new_key] = delete(key)
      if self[new_key].is_a? Hash
        self[new_key].recursive_symbolize_keys
      end
    end
    self
  end
end

module Settings
  mattr_accessor :root
  self.root = File.dirname( File.expand_path(__FILE__) )

  settings = YAML::load( File.read(File.join(root, "settings.yml")) ).recursive_symbolize_keys
  settings.keys.each { |attr| mattr_accessor(attr) }
  settings.each_pair { |attr, val| send("#{attr}=", val) }
end
