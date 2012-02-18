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

$: << File.dirname(__FILE__) + '/..'

require 'test/unit'
require 'rack/test'
require 'fileutils'
require 'json'
require 'nokogiri'
require 'digest/sha1'

# TODO: find a better way to provide test data
FileUtils.copy(File.dirname(__FILE__) + '/mockdata/oneacct.db', '/tmp/oneacct.db') unless File.exists? '/tmp/oneacct.db'

require 'oneacct-server'

set :environment, :test

class OneacctServerTest < Test::Unit::TestCase

  class << self
    def startup
      #
    end
  end

  def test_not_found
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    browser.basic_authorize "oneadmin", Digest::SHA1.hexdigest('onepass')
    browser.get '/not/there'
    assert_equal 'The data you have requested is nowhere to be found.', browser.last_response.body
  end

  def test_wrong_format
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    browser.basic_authorize "oneadmin", Digest::SHA1.hexdigest('onepass')
    browser.get '/html'
    assert_equal 'Unknown format!', browser.last_response.body
  end

  def test_no_auth_error
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    browser.get '/'
    assert_equal 401, browser.last_response.status
  end

  def test_wrong_auth_error
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    browser.basic_authorize "oneadmin", Digest::SHA1.hexdigest('notmypass')
    browser.get '/'
    assert_equal 401, browser.last_response.status
  end

  def test_get_some_json
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    browser.basic_authorize "oneadmin", Digest::SHA1.hexdigest('onepass')
    browser.get '/json'

    assert_nothing_raised {JSON.parse browser.last_response.body}
  end

  def test_get_some_xml
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    browser.basic_authorize "oneadmin", Digest::SHA1.hexdigest('onepass')
    browser.get '/xml'

    assert_nothing_raised {Nokogiri::XML browser.last_response.body}
  end

end