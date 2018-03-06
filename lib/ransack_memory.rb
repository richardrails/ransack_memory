class RansackMemory
  @@config = {}
  cattr_accessor :config

  def initialize(opts = {})
    @opts = opts
  end

end
