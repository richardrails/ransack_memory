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
  include Concerns::RansackMemory # insert this line

  before_action :authenticate_user! # only if you use Devise gem
  before_action :save_and_load_filters # insert this line after Devise auth
end
```

## Configuration

Create file in config/initializers/ransack_memory.rb with this content:

```ruby
RansackMemory.config = {
  param: :q # this means the default Ransack param name for searching. You can change it
}
```

Or you can generate this config file by running ```rails generate ransack_memory``` in console. 

