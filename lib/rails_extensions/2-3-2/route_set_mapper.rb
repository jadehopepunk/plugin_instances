require 'plugin_instances/route_builder'

module ActionController
  module Routing
    class RouteSet #:nodoc:
      class Mapper #:doc:

        def plugin_instances(path, options = {})
          path += "/*instance_plugin_route"
          route = PluginInstances::RouteBuilder.new.build(path, options)
          @set.routes << route
          route
        end

      end
    end
  end
end
