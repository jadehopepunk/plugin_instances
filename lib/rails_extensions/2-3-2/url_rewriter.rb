module PluginInstances
  class UrlRewriter < ActionController::UrlRewriter

    def initialize(request, parameters, route_set)
      @route_set = route_set
      super(request, parameters)
    end
    
    # Given a Hash of options, generates a route
    def rewrite_path(options)
      options = options.symbolize_keys
      options.update(options[:params].symbolize_keys) if options[:params]

      if (overwrite = options.delete(:overwrite_params))
        options.update(@parameters.symbolize_keys)
        options.update(overwrite.symbolize_keys)
      end

      RESERVED_OPTIONS.each { |k| options.delete(k) }
      
      # Generates the query string, too
      @route_set.generate(options, @request.symbolized_path_parameters)      
    end
    
  end
end