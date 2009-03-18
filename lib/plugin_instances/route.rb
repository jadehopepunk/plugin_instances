module PluginInstances
  class Route < ActionController::Routing::Route
    def initialize(path, segments = [], requirements = {}, conditions = {})
      @original_path = path
      super(segments, requirements, conditions)
    end
    
    def plugin_instance_url_prefix(plugin_instance_id)
      parent_path.gsub(/:id/, plugin_instance_id.to_s).chomp('/')
    end
    
    protected
      
        def parent_path
          @original_path.gsub(/\*instance_plugin_route[\/]?/, '')
        end
      
  end
end