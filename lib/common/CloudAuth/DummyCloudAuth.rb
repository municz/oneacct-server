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

module DummyCloudAuth
  def auth(env, params={})
    auth = Rack::Auth::Basic::Request.new(env)

    if auth.provided? && auth.basic?
      username, password = auth.credentials

      if password == 'onepass' && username == 'oneadmin'
        return nil
      else
        return "Authentication failure"
      end
    else
      return "Basic auth not provided"
    end
  end
end