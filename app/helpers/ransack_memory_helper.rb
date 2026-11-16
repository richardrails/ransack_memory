module RansackMemoryHelper
  def clear_filter(opts = {})
    opts = opts.dup
    # The link changes the session with a GET request. Turbo prefetches links
    # on hover, which would cancel the filter without a click.
    opts[:data] = { turbo_prefetch: false }.merge(opts[:data] || {})
    render 'shared/ransack_memory_clear_filter', opts: opts
  end
end
