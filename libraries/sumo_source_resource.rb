class Chef
  class Resource
    class SumoSource < Chef::Resource
      identity_attr :path
      state_attrs :category, :default_timezone, :force_timezone
      provider_base Chef::Provider::SumoSource

      def initialize(name, run_context = nil)
        super
        if name !~ /^[a-z][A-Za-z0-9_-]*$/
          raise Chef::Exceptions::ValidationFailed, "Sumo source #{name} doesn't match ^[a-z][A-Za-z0-9_-]*$!"
        end
        source_attrs = node_source_attributes(run_context)
        @resource_name = :sumo_source
        @action = :create
        @allowed_actions.push(:create, :delete)
        @path = nil
        @default_timezone = source_attrs['default_timezone'] || nil
        @force_timezone = source_attrs['force_timezone'] || nil
        @category = source_attrs['default_category'] || nil
        @automatic_date_parsing = true
        @multiline_processing_enabled = true
        @use_autoline_matching = true
        @manual_prefix_regexp = nil
        @default_date_format = nil
      end

      def path(arg = nil)
        set_or_return(:path, arg, kind_of: String)
      end

      def category(arg = nil)
        set_or_return(:category, arg, kind_of: String)
      end

      def default_timezone(arg = nil)
        set_or_return(:default_timezone, arg, kind_of: String)
      end

      def force_timezone(arg = nil)
        set_or_return(:force_timezone, arg, kind_of: [TrueClass, FalseClass])
      end

      def automatic_date_parsing(arg = nil)
        set_or_return(:automatic_date_parsing, arg, kind_of: [TrueClass, FalseClass])
      end

      def multiline_processing_enabled(arg = nil)
        set_or_return(:multiline_processing_enabled, arg, kind_of: [TrueClass, FalseClass])
      end

      def use_autoline_matching(arg = nil)
        set_or_return(:use_autoline_matching, arg, kind_of: [TrueClass, FalseClass])
      end

      def manual_prefix_regexp(arg = nil)
        set_or_return(:manual_prefix_regexp, arg, kind_of: String)
      end

      def default_date_format(arg = nil)
        set_or_return(:default_date_format, arg, kind_of: String)
      end

      def to_sumo_hash
        {
          type: 'localWildCard',
          name: name,
          timeZone: default_timezone,
          forceTimeZone: force_timezone,
          pathExpression: path,
          category: category,
          sourceType: 'LocalFile',
          automaticDateParsing: automatic_date_parsing,
          multilineProcessingEnabled: multiline_processing_enabled,
          useAutolineMatching: use_autoline_matching,
          manualPrefixRegexp: manual_prefix_regexp,
          defaultDateFormat: default_date_format
        }
      end

      def node_source_attributes(run_context)
        if run_context && run_context.node
          run_context.node[:sumologic][:log_sources]
        else
          {}
        end
      end
    end
  end
end
