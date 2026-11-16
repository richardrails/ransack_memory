module RansackMemory
  module Concern
    extend ActiveSupport::Concern

    DEFAULT_PARAM = :q
    DEFAULT_SESSION_KEY_FORMAT = '%controller_name%_%action_name%_%request_format%'.freeze
    SESSION_KEY_PREFIX = 'ranmemory'.freeze
    # Variables coming from the request (header, URL) are cut to this length
    # so that they can not blow up the session key.
    MAX_KEY_PART_LENGTH = 100

    def save_and_load_filters
      param_name = ransack_memory_config(:param, DEFAULT_PARAM)
      filter_key = ransack_memory_session_key
      page_key = "#{filter_key}_page"
      per_page_key = "#{filter_key}_per_page"

      # Older versions kept one "last filter" shared by all controllers and
      # actions. It is not used anymore, drop it to save space in the session.
      session.delete(:last_q_params)

      # cancel filter if button pressed
      if params[:cancel_filter].to_s == 'true'
        [filter_key, page_key, per_page_key].each { |key| session.delete(key) }
        # do not leak the flag into generated links (pagination, sort links)
        params.delete(:cancel_filter)
      end

      stored_filter = session[filter_key]
      unless stored_filter.is_a?(Hash)
        # a broken value would stay in the session forever
        session.delete(filter_key) unless stored_filter.nil?
        stored_filter = nil
      end

      submitted = params[param_name]
      filter_changed = false

      if submitted.is_a?(ActionController::Parameters) && submitted.present?
        # search term saving
        submitted.permit!
        new_filter = submitted.to_h.to_hash # plain Hash with string keys
        # compared with the filter saved for THIS key, not with the last
        # filter used anywhere in the application
        filter_changed = stored_filter.nil? || stored_filter.to_hash != new_filter
        session[filter_key] = new_filter
      elsif submitted.blank? && stored_filter.present?
        # search term load
        params[param_name] = stored_filter.deep_dup
      end
      # A non-hash value (e.g. ?q=text used by a non-Ransack search) is left alone.

      # per page saving
      per_page_changed = false
      if params[:per_page].present?
        per_page_changed = session[per_page_key].to_s != params[:per_page].to_s
        session[per_page_key] = params[:per_page]
      end

      if filter_changed || per_page_changed
        # the saved page number belongs to the previous result set and may not
        # exist in the new one - start from the first page
        session.delete(page_key)
      elsif params[:page].present?
        # page number saving
        session[page_key] = params[:page]
      end

      # page number load
      params[:page] = session[page_key].presence

      # per page load
      params[:per_page] = session[per_page_key].presence
    end

    # controller method, useful when you want to clear sessions when sign into another user
    def clear_sessions
      session.keys.each do |key|
        session.delete(key) if key.to_s.start_with?(SESSION_KEY_PREFIX)
      end
      session.delete(:last_q_params)
    end

    private

    def ransack_memory_config(name, default)
      (::RansackMemory::Core.config || {})[name].presence || default
    end

    def ransack_memory_session_key
      # set_session_key_identifier may be private in the controller
      user_key = respond_to?(:set_session_key_identifier, true) ? send(:set_session_key_identifier) : nil
      key = user_key.presence&.to_s || ransack_memory_default_session_key
      key.start_with?(SESSION_KEY_PREFIX) ? key : "#{SESSION_KEY_PREFIX}_#{key}"
    end

    def ransack_memory_default_session_key
      variables = {
        'controller_name' => controller_path.parameterize.underscore,
        'action_name' => action_name,
        'request_format' => request.format.try(:symbol).to_s,
        'turbo_frame' => (request.headers['Turbo-Frame'].presence || 'top').to_s[0, MAX_KEY_PART_LENGTH],
        'path_params' => ransack_memory_path_params
      }

      # One pass with a block: values are inserted literally (no backslash
      # sequences) and are never interpolated again.
      ransack_memory_config(:session_key_format, DEFAULT_SESSION_KEY_FORMAT).to_s.gsub(/%(\w+)%/) do |match|
        variables.fetch(Regexp.last_match(1), match)
      end
    end

    # Dynamic segments of the current route, e.g. "project_id-5" for
    # /projects/5/tasks. Lets nested resources keep a filter per parent record.
    def ransack_memory_path_params
      request.path_parameters.except(:controller, :action, :format)
             .sort_by { |name, _| name.to_s }
             .map { |name, value| "#{name}-#{value}" }
             .join('_')[0, MAX_KEY_PART_LENGTH]
    end
  end
end
