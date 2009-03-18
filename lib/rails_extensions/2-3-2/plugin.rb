
class Rails::Plugin
  attr_accessor :initializer
  def require_plugin(plugin_name)
    initializer.configuration.plugin_locators.each do |locator|
      locator.new(initializer).each do |plugin_loader|
        return plugin_loader.load(initializer) if plugin_loader.name.to_s == plugin_name.to_s
      end
    end
    raise "Plugin '#{plugin_name}' does not exist"
  end

  def load_with_plugin_instances(initializer)
    @initializer = initializer
    return if PluginInstances::Manager.plugin_exists?(directory)
    plugin = PluginInstances::Manager.register_plugin(directory) do
      load_without_plugin_instances(initializer)
    end
    # TODO: Can we use Initializer::Configuration#default_load_paths to do this?
    initializer.configuration.controller_paths << plugin.controllers_path
  end
  alias_method_chain :load, :plugin_instances
end