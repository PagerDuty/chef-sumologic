require 'net/https'
require 'uri'
require 'json'

class Chef
  class Provider
    class SumoSource < Chef::Provider

      def initialize(new_resource, run_context)
        super(new_resource, run_context)
      end

      def whyrun_supported?
        true
      end

      def load_current_resource
        unless node[:sumologic][:disabled]
        databag_secret = Chef::EncryptedDataBagItem.load_secret(node[:sumologic][:credentials][:secret_file])
        databag_creds = Chef::EncryptedDataBagItem.load(node[:sumologic][:credentials][:bag_name], node[:sumologic][:credentials][:item_name], databag_secret)
        @@collector ||= Sumologic::Collector.new(name: node.name,
                api_username: databag_creds['userID'] || node[:sumologic][:userID],
                api_password: databag_creds['password'] || node[:sumologic][:password]
                )

          @current_resource = Chef::Resource::SumoSource.new(@new_resource.name)
          @current_resource.path(@new_resource.path)
          @current_resource.category(@new_resource.category)
          @current_resource.default_timezone(@new_resource.default_timezone)
          @current_resource.force_timezone(@new_resource.force_timezone)
          @current_resource.automatic_date_parsing(@new_resource.automatic_date_parsing)
          @current_resource.multiline_processing_enabled(@new_resource.multiline_processing_enabled)
          @current_resource.use_autoline_matching(@new_resource.use_autoline_matching)
          @current_resource.manual_prefix_regexp(@new_resource.manual_prefix_regexp)
          @current_resource.default_date_format(@new_resource.default_date_format)
          if @@collector.source_exist?(@new_resource.name) and (not node[:sumologic][:disabled])
            resource_hash = @@collector.source(@new_resource.name)
            @current_resource.path(resource_hash['pathExpression'])
            @current_resource.default_timezone(resource_hash['timeZone'])
            @current_resource.force_timezone(resource_hash['forceTimeZone'])
            @current_resource.category(resource_hash['category'])
            @current_resource.automatic_date_parsing(resource_hash['automaticDateParsing'])
            @current_resource.multiline_processing_enabled(resource_hash['multilineProcessingEnabled'])
            @current_resource.use_autoline_matching(resource_hash['useAutolineMatching'])
            @current_resource.manual_prefix_regexp(resource_hash['manualPrefixRegexp'])
            @current_resource.default_date_format(resource_hash['defaultDateFormat'])
          end
          @current_resource
        end
      end

      def action_create
        unless node[:sumologic][:disabled]
          if @@collector.source_exist?(new_resource.name)
            if sumo_source_different?
              converge_by( "replace #{new_resource.name} via api\n" + convergence_description) do
                @@collector.update_source!(@@collector.source(new_resource.name)["id"], new_resource.to_sumo_hash)
                @@collector.refresh!
              end
              @new_resource.updated_by_last_action(true)
              Chef::Log.info("#{@new_resource} replaced sumo_source entry")
            else
              # resource is present and its same as specified
            end
          else
            converge_by("add #{new_resource.name} via sumologic api\n" + new_resource.to_sumo_hash.to_s)  do
              @@collector.add_source!(new_resource.to_sumo_hash)
              @@collector.refresh!
            end
            @new_resource.updated_by_last_action(true)
            Chef::Log.info("#{@new_resource} added sumo_source entry")
          end
        else
          Chef::Log.debug("Skipping sumo source declaration as sumologic::disabled is set to true")
        end
      end

      def action_delete
        unless node[:sumologic][:disabled]
          if @@collector.source_exist?(@new_resource.name)
            converge_by "removing sumo source #{@new_resource.name}" do
              raise ArgumentError , "Not implemented yet"
            end
            @new_resource.updated_by_last_action(true)
            Chef::Log.info("#{@new_resource} deleted sumo_source entry")
          end
        else
          Chef::Log.debug("Skipping sumo source declaration as sumologic::disabled is set to true")
        end
      end

      private
      def sumo_source_different?
        Chef::Resource::SumoSource.state_attrs.any? do |attr|
          @current_resource.send(attr) != @new_resource.send(attr)
        end
      end

      def convergence_description
        description = ""
        Chef::Resource::SumoSource.state_attrs.each do |attr|
          current_value = @current_resource.send(attr)
          new_value = @new_resource.send(attr)
          if current_resource != new_value
              description << "value of #{attr} will change from '#{current_value}' to '#{new_value}'\n"
          end
        end
        description
      end
    end
  end
end
