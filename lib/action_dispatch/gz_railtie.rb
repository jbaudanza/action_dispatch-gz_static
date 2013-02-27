module ActionDispatch
  class GzRailtie < Rails::Railtie
    initializer "gz_static.install_middleware" do |app|
      app.middleware.swap ::ActionDispatch::Static, ::ActionDispatch::GzStatic,
          app.paths['public'].first,
          app.config.static_cache_control
    end
  end
end