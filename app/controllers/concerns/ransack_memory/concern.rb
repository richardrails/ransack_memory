module RansackMemory
  module Concern
    extend ActiveSupport::Concern

    def save_and_load_filters
      session_key_identifier = ::RansackMemory::Core.config[:session_key_format]
        .gsub('%controller_name%', controller_name)
        .gsub('%action_name%', action_name)
        .gsub('%request_format%', request.format.symbol.to_s)

      session_key_base = "ranmemory_#{session_key_identifier}"

      # permit search params
      params[::RansackMemory::Core.config[:param]].permit! if params[::RansackMemory::Core.config[:param]].present? && params[::RansackMemory::Core.config[:param]].respond_to?(:permit)

      # cancel filter if button pressed
      if params[:cancel_filter] == "true"
        session["#{session_key_base}"] = nil
        session["#{session_key_base}_page"] = nil
        session["#{session_key_base}_per_page"] = nil
      end

      # search term saving
      session["#{session_key_base}"] = params[::RansackMemory::Core.config[:param]] if params[::RansackMemory::Core.config[:param]].present?

      # page number saving
      session["#{session_key_base}_page"] = params[:page] if params[:page].present?

      # per page saving
      session["#{session_key_base}_per_page"] = params[:per_page] if params[:per_page].present?

      # search term load
      params[::RansackMemory::Core.config[:param]] = session["#{session_key_base}"].presence

      # page number load
      params[:page] = session["#{session_key_base}_page"].presence

      # per page load
      params[:per_page] = session["#{session_key_base}_per_page"].presence

      # set page number to 1 if filter has changed
      if (params[::RansackMemory::Core.config[:param]].present? && session[:last_q_params] != params[::RansackMemory::Core.config[:param]]) || (params[:cancel_filter].present? && session["#{session_key_base}_page"] != params[:page])
        params[:page] = nil
        session["#{session_key_base}_page"] = nil
      end

      session[:last_q_params] = params[::RansackMemory::Core.config[:param]]

      # session[:last_page] = params[:page]
    end

    # controller method, useful when you want to clear sessions when sign into another user
    def clear_sessions
      session.keys.each do |key|
        session.delete(key) if key =~ /ranmemory_/
      end
    end
  end
end
