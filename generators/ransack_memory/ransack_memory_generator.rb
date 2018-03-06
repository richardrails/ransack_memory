class RansackMemoryGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file "ransack_memory.rb", "config/initializers/ransack_memory.rb"
    end
  end
end
