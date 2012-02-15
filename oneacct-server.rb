###########################################################################
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##    http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
###########################################################################

$: << File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'yaml'
require 'sequel'
require 'sqlite3'

CONFIGURATION_DIR = File.dirname(__FILE__) + '/etc'
CONFIGURATION_FILE = CONFIGURATION_DIR + '/oneacct-server.conf'

# load configuration
begin
  CONF = YAML.load_file(CONFIGURATION_FILE)
rescue Exception => e
  puts "Error parsing config file #{CONFIGURATION_FILE}: #{e.message}"
  exit 1
end

# prepare access to the DB
begin
  raise Exception.new "File does not exist!" unless File.exists? CONF[:DB].sub /^sqlite:\/\//, ''
  DB = Sequel.connect(CONF[:DB])
rescue Exception => e
  puts "Error opening DB file: #{CONF[:DB]}; #{e.message}"
  exit 1
end

require 'OneacctServer'

CloudServer.print_configuration(CONF)

#
use Rack::Session::Pool, :key => 'oneacct'
set :config, CONF
set :host, settings.config[:server]
set :port, settings.config[:port]

# helpers
before do

  @oneacct_server = OneacctServer.new(settings.config)

  begin
    result = @oneacct_server.authenticate(request.env)
  rescue Exception => e
    error 500, e.message
  end

  if result
    error 401, result
  end
end

get '/:format?' do

  if params[:format]
    @oneacct_server.get_data Hash.new, params[:format].to_sym
  else
    @oneacct_server.get_data Hash.new
  end
end

post '/:format?' do
  options = Hash.new
  options[:start] = params[:from_time]
  options[:end] = params[:to_time]
  options[:user] = params[:for_user]

  if params[:format]
    @oneacct_server.get_data options, params[:format].to_sym
  else
    @oneacct_server.get_data options
  end
end

not_found do
  'The data you have requested is nowhere to be found.'
end

error do
  'Ooops. ' + env['sinatra.error'].message
end