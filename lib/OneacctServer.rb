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

$: << File.dirname(__FILE__) + '/common'

# Common cloud libs
require 'CloudServer'
require 'acct/acct_helper'

class OneacctServer < CloudServer
  def initialize(config)
    super(config)

    if config[:ssl_server]
      @base_url=config[:ssl_server]
    else
      @base_url="http://#{config[:server]}:#{config[:port]}"
    end
  end

  def get_data(options)
    acct_helper=AcctHelper.new
    filters=Hash.new

# TODO: forward options here
    filters[:start]=options[:start].to_i if options[:start]
    filters[:end]=options[:end].to_i if options[:end]
    filters[:user]=options[:user].to_i if options[:user]

# TODO: select the right format
    #acct_helper.gen_json(filters)
    acct_helper.gen_xml(filters)
  end
end