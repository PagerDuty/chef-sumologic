class Chef
  class Resource
    class SumoSource < Chef::Resource
      identity_attr :path
      state_attrs :category, :default_timezone, :force_timezone
      provider_base Chef::Provider::SumoSource

      def initialize(name, run_context=nil)
        super
        if name !~ /^[a-z][A-Za-z0-9_-]*$/
          raise Chef::Exceptions::ValidationFailed, "Sumo source #{name} doesn't match ^[a-z][A-Za-z0-9_-]*$!"
        end
        @resource_name = :sumo_source
        @action = :create
        @allowed_actions.push(:create, :delete)
        @path =nil
        @default_timezone = nil
        @force_timezone = nil
        @category = nil
      end

      def path(arg=nil)
        set_or_return(:path, arg, :kind_of => String)
      end

      def category(arg=nil)
        set_or_return(:category, arg, :kind_of => String)
      end

      def default_timezone(arg=nil)
        set_or_return(:default_timezone, arg, :kind_of => String)
      end

      def force_timezone(arg=false)
        set_or_return(:force_timezone, arg, :kind_of => [TrueClass, FalseClass])
      end

      def to_sumo_hash
        { type: 'localWildCard', name: name, timeZone: default_timezone,
        forceTimeZone: force_timezone, pathExpression: path, category: category,
        sourceType: 'LocalFile'
        }
      end
    end
  end
end
