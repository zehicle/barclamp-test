# Copyright 2013, Dell
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
# This model is a stub for the Jig override system
# It is NOT installed by default, but can be used for testing or as a model

require 'json'

class BarclampTest::Jig < Jig

  def run(nr, data)
    raise "Cannot call TestJig::Run on #{nr.name}" unless nr.state == NodeRole::TRANSITION

    Node.transaction do
      begin
        # create tests data
        disco = { :test=> { :random => Random.rand(1000000), :marker => data["marker"] }, data["marker"] => nr.id }
        nr.node.discovery = disco
        nr.node.save!
        # running the actions from the node role
        Rails.logger.info("TestJig Running node-role: #{nr.to_s}")    
        %x[touch /tmp/test-jig-node-role-test-#{data["marker"] || nr.name}.txt]
        o = "TEST JIG >> Working #{nr.node.name} #{data["marker"]} & pausing for #{data["delay"]}"
        puts o
        Rails.logger.info o
        nr.runlog = o
        # we want an easy way to turn off the delay setting
        if data["test"] || true or data["test"].eql? "true"
          sleep data["delay"].to_i || 0
        end
        raise "test-fails role always fails" if nr.role.  name.eql? 'test-fails'
        nr.state = NodeRole::ACTIVE
      rescue Exception => e
        nr.status = e.to_s
        nr.state = NodeRole::ERROR
      end
      nr.save!
    end
  end

  def stage_run(nr)
    Rails.logger.info "BarclampTest::Jig.stage_run > '#{nr.role.name}' on '#{nr.node.name}'"
    return nr.all_my_data
  end

  def create_node(node)
    %x[touch /tmp/test-jig-node-#{node.name}]
    Rails.logger.info("TestJig Creating node: #{node.name}")
  end

  def delete_node(node)
    %x[rm /tmp/test-jig-node-#{node.name}]
    Rails.logger.info("TestJig Deleting node: #{node.name}")    
  end
  
end


