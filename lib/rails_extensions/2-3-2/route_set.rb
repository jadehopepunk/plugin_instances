module ActionController
  module Routing
    class RouteSet      
      
      def call(env)
        request = Request.new(env)
        
        params = recognize_path(request.path, extract_request_environment(request))
        return call_instance_plugin(request, env).to_a if params && params[:instance_plugin_route]
        
        app = Routing::Routes.recognize(request)
        app.call(env).to_a
      end

      protected
      
        def call_instance_plugin(request, env)
          request, controller_class, plugin_instance, parent_route = load_instance_plugin_request(request)
          
          # RAILS HACK: For global rescue to have access to the original request and response          
          request = env["action_controller.rescue.request"] ||= request
          response = env["action_controller.rescue.response"] ||= Response.new          
          
          controller_class.process_plugin_instance(request, response, plugin_instance, parent_route)
        end

        def load_instance_plugin_request(request)
          environment = extract_request_environment(request)
          segments = to_plain_segments(request.path)
          parent_route = find_applicable_plugin_instance_route(request.path, environment)
          
          plugin_instance_id = get_plugin_instance_id(segments, request.path, environment)
          plugin_instance = find_plugin_instance(plugin_instance_id)
          route_set = PluginInstances::RouteSetManager.routes_for(plugin_instance.plugin_name)
          
          new_params = route_set.recognize_path(plugin_path(request.path), environment).merge(:plugin_instance_id => plugin_instance_id)
          request.path_parameters = new_params.with_indifferent_access
          
          [request, route_set.controller_class_from_params(new_params), plugin_instance, parent_route]
        end
        
        def find_applicable_plugin_instance_route(path, environment)
          routes.detect { |r| r.recognize(path) } 
        end
        
        def find_plugin_instance(plugin_instance_id)
          PluginInstance.find(plugin_instance_id)
        end
      
        def get_plugin_instance_id(segments, path, environment)
          # TODO: pages shouldn't be hard coded
          if segments.length >= 2 && segments[0] == 'pages'
            segments[1]
          else
            raise RoutingError, "No Plugin Instance route matches #{path.inspect} with #{environment.inspect}"
          end
        end
      
        def plugin_path(path)
          # TODO: pages shouldn't be hard coded
          path.gsub(/^\/pages\/[^\/?]*/, '')
        end
      
    end
  end
end