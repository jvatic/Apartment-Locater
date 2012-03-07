# encoding: utf-8
require 'sinatra'
require './database'
require './helpers'

configure :development do |config|
  require 'sinatra/reloader'
  config.also_reload "*.rb"
end

get '/' do
  erb :application
end

get '*.js' do
  content_type "application/javascript"
  path = File.join(File.dirname(__FILE__), 'script', params[:splat].join('/'))
  js_path     = path.dup << '.js'
  coffee_path = path.dup << '.coffee'

  if File.exists?(js_path)
    File.read(js_path)
  else
    coffee params[:splat].join('/').to_sym
  end
end

get '*.css' do
  content_type 'text/css'
  path = File.join( Sinatra::Application.root, 'views', params[:splat].join('/') )
  css_path  = path.dup << '.css'
  sass_path = path.dup << '.sass'

  if File.exists?(css_path)
    File.read(css_path)
  else
    sass params[:splat].join('/').to_sym
  end
end

