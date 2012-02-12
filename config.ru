$: << File.dirname(__FILE__)

require 'oneacct-server'

disable :run
set :root, File.dirname(__FILE__)

run Sinatra::Application