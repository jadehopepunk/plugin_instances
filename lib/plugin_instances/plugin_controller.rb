
module PluginInstances
  class PluginController < ApplicationController
    attr_accessor :plugin_instance, :parent_route

    def self.process_plugin_instance(request, response, plugin_instance, parent_route)
      new.process_plugin_instance(request, response, plugin_instance, parent_route)
    end

    def process_plugin_instance(request, response, plugin_instance, parent_route)
      self.plugin_instance = plugin_instance
      self.parent_route = parent_route
      process(request, response)
    end
  
    def initialize_current_url
      @url = PluginInstances::UrlRewriter.new(request, params.clone, route_set)
    end

    def url_for(options = {})
      add_plugin_url_prefix(super)
    end
    
    def route_set
      PluginInstances::RouteSetManager.routes_for(plugin_name)
    end
    
    def self.controller_path_without_namespace
      without_top_module(name).gsub(/Controller$/, '').underscore
    end
            
    protected
    
      def self.without_top_module(name)
        name.split("::")[1..-1].join('::')
      end
    
      def add_plugin_url_prefix(url)
        uri = URI.parse(url)
        uri.path = url_prefix + uri.path
        uri.to_s
      end
      
      def url_prefix
        parent_route.plugin_instance_url_prefix(plugin_instance.to_param)
      end
    
      def plugin_name
        plugin_instance.plugin_name
      end
    
  end
end

