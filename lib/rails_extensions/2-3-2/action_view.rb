ActionView::Base.class_eval do
  def initialize_with_plugin_instances(*args)
    initialize_without_plugin_instances *args

    PluginInstances::Manager.plugins.reverse.each do |plugin|
      view_paths << plugin.templates_path
    end
  end
  alias_method_chain :initialize, :plugin_instances
end