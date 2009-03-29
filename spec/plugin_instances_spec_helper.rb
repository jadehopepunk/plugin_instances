require File.expand_path(File.dirname(__FILE__) + "/factories.rb")

module ActionController
  class TestCase

    def setup_controller_request_and_response_with_plugin_instance
      @request = TestRequest.new
      @response = TestResponse.new

      if klass = self.class.controller_class
        @controller ||= klass.new rescue nil
      end

      if @controller        
        @controller.request = @request
        @controller.params = {}
      end
    end

    alias_method_chain :setup_controller_request_and_response, :plugin_instance
  end  
end


module ActionController #:nodoc:
  module TestProcess
    
    def process(action, parameters = nil, session = nil, flash = nil, http_method = 'GET')
      # Sanity check for required instance variables so we can give an
      # understandable error message.
      %w(@controller @request @response).each do |iv_name|
        if !(instance_variable_names.include?(iv_name) || instance_variable_names.include?(iv_name.to_sym)) || instance_variable_get(iv_name).nil?
          raise "#{iv_name} is nil: make sure you set it in your test's setup method."
        end
      end

      @request.recycle!
      @response.recycle!

      @html_document = nil
      @request.env['REQUEST_METHOD'] = http_method

      @request.action = action.to_s

      parameters ||= {}
      if @controller.respond_to?(:route_set)
        @request.assign_parameters(@controller.send(:route_set), @controller.class.controller_path_without_namespace, action.to_s, parameters)
      else
        @request.assign_parameters(ActionController::Routing::Routes, @controller.class.controller_path, action.to_s, parameters)
      end

      @request.session = ActionController::TestSession.new(session) unless session.nil?
      @request.session["flash"] = ActionController::Flash::FlashHash.new.update(flash) if flash
      build_request_uri(action, parameters)

      Base.class_eval { include ProcessWithTest } unless Base < ProcessWithTest
      @controller.process_with_test(@request, @response)
    end


    def build_request_uri(action, parameters)
      unless @request.env['REQUEST_URI']
        options = @controller.__send__(:rewrite_options, parameters)
        options.update(:only_path => true, :action => action)

        
        route_set = @controller.respond_to?(:route_set) ? @controller.route_set : ActionController::Routing::Routes
        url = PluginInstances::UrlRewriter.new(@request, parameters.clone, route_set)
        @request.set_REQUEST_URI(url.rewrite(options))
      end
    end
    
  end
end


module ActionController #:nodoc:
  class TestRequest < Request #:nodoc:
    def assign_parameters(route_set, controller_path, action, parameters)
      parameters = parameters.symbolize_keys.merge(:controller => controller_path, :action => action)
      extra_keys = route_set.extra_keys(parameters)
      non_path_parameters = get? ? query_parameters : request_parameters
      parameters.each do |key, value|
        if value.is_a? Fixnum
          value = value.to_s
        elsif value.is_a? Array
          value = ActionController::Routing::PathSegment::Result.new(value)
        end

        if extra_keys.include?(key.to_sym)
          non_path_parameters[key] = value
        else
          path_parameters[key.to_s] = value
        end
      end
      raw_post # populate env['RAW_POST_DATA']
      @parameters = nil # reset TestRequest#parameters to use the new path_parameters
    end
  end
end