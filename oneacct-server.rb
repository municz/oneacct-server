$: << File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'yaml'

get '/' do
  "Hello, I'm OpenNebula's new accounting server."
end