module PluginInstances
  class RouteSetManager
    @@route_sets = {}
    
    def self.routes_for(plugin_name)
      @@route_sets[plugin_name] ||= PluginInstances::RouteSet.new(plugin_name)
    end
  end
end