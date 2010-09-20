module PostgisAdapter
  class Railtie < Rails::Railtie
    initializer "postgis adapter" do
      require "postgis_adapter"
    end
  end
end
