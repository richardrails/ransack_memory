if defined?(Rails)

  # Rails3 generator invoked with 'rails generate ransack_memory'
  class RansackMemoryGenerator < Rails::Generators::Base
    source_root(File.expand_path(File.dirname(__FILE__) + "/../../generators/ransack_memory/templates"))
    def copy_initializer
      copy_file 'ransack_memory.rb', 'config/initializers/ransack_memory.rb'
    end
  end

end