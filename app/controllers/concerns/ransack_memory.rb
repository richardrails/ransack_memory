module Concerns
  module RansackMemory
    extend ActiveSupport::Concern

    def save_and_load_filters

      # cancel filter if button pressed
      if params[:cancel_filter].present? && params[:cancel_filter] == "true"
        @selected_filter = nil
        session["#{controller_name}_#{action_name}_#{request.xhr?}"] = nil
        session["#{controller_name}_#{action_name}_#{request.xhr?}_page"] = nil
      end

      if user_signed_in?
        # search term saving
        session["#{controller_name}_#{action_name}_#{request.xhr?}"] = params[RansackMemory.config[:param]] if params[RansackMemory.config[:param]].present?

        # page number saving
        session["#{controller_name}_#{action_name}_#{request.xhr?}_page"] = params[:page] if params[:page].present?

        # per page saving
        session["#{controller_name}_#{action_name}_#{request.xhr?}_per_page"] = params[:per_page] if params[:per_page].present?
      end

      if user_signed_in?
        # search term load
        if session["#{controller_name}_#{action_name}_#{request.xhr?}"]
          params[RansackMemory.config[:param]] = session["#{controller_name}_#{action_name}_#{request.xhr?}"]
        else
          params[RansackMemory.config[:param]] = nil
        end

        # page number load
        if session["#{controller_name}_#{action_name}_#{request.xhr?}_page"]
          params[:page] = session["#{controller_name}_#{action_name}_#{request.xhr?}_page"]
        else
          params[:page] = nil
        end

        # set page number to 1 if filter has changed
        if (params[RansackMemory.config[:param]] && session[:last_q_params] != params[RansackMemory.config[:param]]) || (params[:cancel_filter].present? && session["#{controller_name}_#{action_name}_#{request.xhr?}_page"] != params[:page])
          params[:page] = nil
          session["#{controller_name}_#{action_name}_#{request.xhr?}_page"] = nil
        end
        session[:last_q_params] = params[RansackMemory.config[:param]]

        # per page load
        if session["#{controller_name}_#{action_name}_#{request.xhr?}_per_page"]
          params[:per_page] = session["#{controller_name}_#{action_name}_#{request.xhr?}_per_page"]
        else
          params[:per_page] = nil
        end
      end
    end
  end
end
