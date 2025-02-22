RansackMemory::Core.config = {
  # This means the default Ransack param name for searching. You can change it
  param: :q,

  # This means how the key used to store the information to the session
  # will be stored. Currently it interpolates request parameters.
  # You can customize it and use these vars to build a key that fits your needs
  #
  # Available variables are:
  #   controller_name
  #   action_name
  #   request_format
  #   turbo_frame
<% if defined? Turbo -%>
  session_key_format: '%controller_name%_%action_name%_%request_format%_%turbo_frame%'
<% else -%>
  session_key_format: '%controller_name%_%action_name%_%request_format%'
<% end -%>
}
