$: << File.dirname(__FILE__) + '/..'

require 'test/unit'
require 'rack/test'
require 'fileutils'
require 'json'
require 'nokogiri'

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
    browser.basic_authorize "oneadmin", "onepass"
    browser.get '/not/there'
    assert_equal 'The data you have requested is nowhere to be found.', browser.last_response.body
  end

  def test_wrong_format
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    browser.basic_authorize "oneadmin", "onepass"
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
    browser.basic_authorize "oneadmin", "notmypass"
    browser.get '/'
    assert_equal 401, browser.last_response.status
  end

  def test_get_some_json
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    browser.basic_authorize "oneadmin", "onepass"
    browser.get '/json'

    assert_nothing_raised {JSON.parse browser.last_response.body}
  end

  def test_get_some_xml
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    browser.basic_authorize "oneadmin", "onepass"
    browser.get '/xml'

    assert_nothing_raised {Nokogiri::XML browser.last_response.body}
  end

end