module PluginInstances
  class RouteSet < ActionController::Routing::RouteSet
    
    def initialize(plugin_name)
      super()
      @plugin_name = plugin_name
    end
    
    def recognize_path(path, environment={})
      super
    rescue ActionController::RoutingError => e
      raise ActionController::RoutingError, e.message + " for plugin \"#{@plugin_name}\""
    end
    
    def controller_class_from_params(params)
      "#{namespace_name}::#{params[:controller].camelize}Controller".constantize
    end

    protected
          
      def namespace_name
        @plugin_name.camelize
      end
    
  end
end