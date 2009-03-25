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