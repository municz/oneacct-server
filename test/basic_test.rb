$: << File.dirname(__FILE__) + '/..'

require 'test/unit'
require 'rack/test'
require 'fileutils'

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
    # TODO: this test will always fail without Basic Auth data
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    browser.get '/not_there'
    assert_equal 'This is nowhere to be found.', browser.last_response.body
  end

  def test_auth_error
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    browser.get '/'
    assert_equal 401, browser.last_response.status
  end

end