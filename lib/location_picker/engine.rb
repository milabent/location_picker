module LocationPicker
  module Rails
    class Engine < ::Rails::Engine
      config.autoload_paths += Dir["#{config.root}/lib/**/"]
      config.autoload_paths += Dir["#{config.root}/app/controllers/**/"]
    end
  end
end