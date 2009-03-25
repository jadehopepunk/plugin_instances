module PluginInstances
  class MockRoute < ActionController::Routing::Route
    def plugin_instance_url_prefix(plugin_instance_id)
      "/prefix"
    end
  end
end