if defined?(Rails)

  # Rails3 generator invoked with 'rails generate ransack_memory'
  class RansackMemoryGenerator < Rails::Generators::Base
    source_root(File.expand_path(File.dirname(__FILE__) + "/../templates/ransack_memory"))
    def copy_initializer

      copy_file 'ransack_memory_template.rb', 'config/initializers/ransack_memory.rb'
    end
  end

end