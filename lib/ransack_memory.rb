module RansackMemory

  require 'ransack_memory/version'
  require 'ransack_memory/engine' if defined?(::Rails)

  class Core
    @@config = {}
    cattr_accessor :config

    def initialize(opts = {})
      @opts = opts
    end
  end

end
