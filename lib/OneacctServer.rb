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

# common cloud libs
require 'CloudServer'
require 'acct/acct_helper'

class OneacctServer < CloudServer

  def initialize(config)

    super(config)

    # fix base_url if using SSL proxy
    if config[:ssl_server]
      @base_url=config[:ssl_server]
    else
      @base_url="http://#{config[:server]}:#{config[:port]}"
    end

  end

  def get_data(options, format = :json)

    # instantiate helper with access to OpenNebula's accounting subsystem
    # this is a modified version of the helper from the Accounting Toolset
    acct_helper=AcctHelper.new

    # convert Strings to integers
    filters=Hash.new
    filters[:start]=options[:start].to_i if options[:start]
    filters[:end]=options[:end].to_i if options[:end]
    filters[:user]=options[:user].to_i if options[:user]

    # call the right output formatter
    case format
      when :json
        acct_helper.gen_json filters
      when :xml
        acct_helper.gen_xml filters
      else
        [400, "Unknown format!"]
    end

  end

end