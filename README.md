# Ransack Memory

This Gem provides automatic saving your filtered Ransack gem params into Rails session. It also autoloads params from session to your search forms.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'ransack_memory'
```

Add this line to your basic controller (typically ApplicationController):

```ruby
class ApplicationController < ActionController::Base
  include RansackMemory::Concern # insert this line

  before_action :authenticate_user! # only if you use Devise gem
  before_action :save_and_load_filters # insert this line after Devise auth before filter (Devise gem is not necessary)
end
```

Add this in your views where you have search forms. This is clear button, which deletes ransack memory sessions.
```erb
<%= clear_filter %>
```
You can pass any of link attributes:

```erb
<%= clear_filter, title: 'Clear Filter', class: 'btn btn-primary', data: {confirm: 'Really?', my_data: 'something'} %>
```

## Configuration

Create file in config/initializers/ransack_memory.rb with this content:

```ruby
RansackMemory::Core.config = {
  param: :q, # this means the default Ransack param name for searching. You can change it
  session_key_format: '%controller_name%_%action_name%_%request_format%' # this means how the key used to store the information to the session will be stored. Currently it interpolates request parameters. You can customize it and use these vars to build a key that fits your needs
}
```

Or you can generate this config file by running ```rails generate ransack_memory``` in console. 

## Kaminari issue

When you have an issue with Kaminari gem, that you can't go back to the first page, update your kaminari view in `app/views/kaminari/_first_page.html.erb`:
```erb
<%= link_to_unless current_page.first?, t('views.pagination.first').html_safe, url_for(params.merge({page: 1, cancel_filter: nil})), remote: remote, class: 'btn btn-secondary' %>
```
