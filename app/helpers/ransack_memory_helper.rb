module RansackMemoryHelper
  def clear_filter(opts = {})
    render 'shared/ransack_memory_clear_filter', opts: opts
  end
end