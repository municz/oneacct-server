# --------------------------------------------------------------------------
# Copyright 2010-2011, C12G Labs S.L.
#
# This file is part of OpenNebula addons.
#
# OpenNebula addons are free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or the hope That it will be useful, but (at your
# option) any later version.
#
# OpenNebula addons are distributed in WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License
# along with OpenNebula addons. If not, see
# <http://www.gnu.org/licenses/>
# --------------------------------------------------------------------------

$: << File.dirname(__FILE__)

require 'oneacct'
require 'json'

class AcctHelper

    def gen_accounting(filters)
        acct=AcctClient.new(filters)
        acct.account()
    end

    def gen_json(filters)
        acct=gen_accounting(filters)
        acct.to_json
    end

    def gen_xml(filters)
        acct=gen_accounting(filters)

        xml=""

        acct.each do |user, data|
            xml<<"<user id=\"#{user}\">\n"

            data[:vms].each do |vmid, vm|
                xml<<"  <vm id=\"#{vmid}\">\n"

                xml<<"    "<<xml_tag(:name, vm[:name])
                xml<<"    "<<xml_tag(:time, vm[:time])
                xml<<"    "<<xml_tag(:cpu, vm[:slices].first[:cpu])
                xml<<"    "<<xml_tag(:mem, vm[:slices].first[:mem])
                xml<<"    "<<xml_tag(:net_rx, vm[:network][:net_rx])
                xml<<"    "<<xml_tag(:net_tx, vm[:network][:net_tx])

                vm[:slices].each do |slice|
                    xml<<"    <slice seq=\"#{slice[:seq]}\">\n"

                    slice.each do |key, value|
                        xml<<"      "<<xml_tag(key, value)
                    end

                    xml<<"    </slice>\n"
                end

                xml<<"  </vm>\n"
            end

            xml<<"</user>\n"
        end

        xml
    end

private

    def xml_tag(tag, value)
        "<#{tag}>#{value}</#{tag}>\n"
    end

end







