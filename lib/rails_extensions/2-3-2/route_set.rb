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
          results = load_instance_plugin_request(request)
          if results.is_a?(Array)
            request, controller_class, plugin_instance, parent_route = results
          
            # RAILS HACK: For global rescue to have access to the original request and response          
            request = env["action_controller.rescue.request"] ||= request
            response = env["action_controller.rescue.response"] ||= Response.new
          
            controller_class.process_plugin_instance(request, response, plugin_instance, parent_route)
          else
            call_plugin_not_found(request, env, results)
          end
        end

        # Your might want to override this in your application
        def call_plugin_not_found(request, env, plugin_instance_id)
          raise "Plugin Not Found"
        end
        
        def call_redirect(request, options)
          url = UrlRewriter.new(request, options.clone).rewrite(options)        
          response = Response.new
          response.redirect(url, 302)
          response.prepare!
          response.to_a
        end
      
        def load_instance_plugin_request(request)
          environment = extract_request_environment(request)
          segments = to_plain_segments(request.path)
          parent_route = find_applicable_plugin_instance_route(request.path, environment)
          
          plugin_instance_id = get_plugin_instance_id(segments, request.path, environment)
          plugin_instance = find_plugin_instance(plugin_instance_id)
          
          if plugin_instance
            load_request_for_instance_plugin(request, plugin_instance, plugin_instance_id, parent_route)
          else
            plugin_instance_id
          end
        end
        
        def load_request_for_instance_plugin(request, plugin_instance, plugin_instance_id, parent_route)
          route_set = PluginInstances::RouteSetManager.routes_for(plugin_instance.plugin_name)
          environment = extract_request_environment(request)
          
          new_params = route_set.recognize_path(plugin_path(request.path), environment).merge(:plugin_instance_id => plugin_instance.to_param)
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