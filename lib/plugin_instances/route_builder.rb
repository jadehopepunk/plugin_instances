
module PluginInstances
  class RouteBuilder < ActionController::Routing::RouteBuilder

    # Construct and return a route with the given path and options.
    def build(path, options)
      # Wrap the path with slashes
      path = "/#{path}" unless path[0] == ?/
      path = "#{path}/" unless path[-1] == ?/

      prefix = options[:path_prefix].to_s.gsub(/^\//,'')
      path = "/#{prefix}#{path}" unless prefix.blank?

      segments = segments_for_route_path(path)
      defaults, requirements, conditions = divide_route_options(segments, options)
      requirements = assign_route_options(segments, defaults, requirements)

      # TODO: Segments should be frozen on initialize
      segments.each { |segment| segment.freeze }

      route = Route.new(path, segments, requirements, conditions)

      route.freeze
    end

  end  
end


