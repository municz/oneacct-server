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

require 'OneacctServer'

CONFIGURATION_DIR = File.dirname(__FILE__) + '/etc'
CONFIGURATION_FILE = CONFIGURATION_DIR + '/oneacct-server.conf'

# load configuration
begin
  conf = YAML.load_file(CONFIGURATION_FILE)
rescue Exception => e
  puts "Error parsing config file #{CONFIGURATION_FILE}: #{e.message}"
  exit 1
end

CloudServer.print_configuration(conf)

#
use Rack::Session::Pool, :key => 'oneacct'
set :config, conf
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

# actions
get '/' do
  "Hello, I'm OpenNebula's new accounting server."
end