ENV['RAILS_ENV'] = 'test'

require 'logger'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'ransack_memory'

class RansackMemoryTestApp < Rails::Application
  config.root = File.expand_path('..', __dir__)
  config.eager_load = false
  config.secret_key_base = 'ransack_memory_test_secret_key_base' * 3
  config.hosts.clear
  config.logger = Logger.new(nil)
  config.active_support.deprecation = :silence
end

RansackMemoryTestApp.initialize!

RansackMemoryTestApp.routes.draw do
  resources :projects, only: :index do
    get :archive, on: :collection
    get :shared, on: :collection
    get :clear, on: :collection
    get :keys, on: :collection
    get :link, on: :collection
    resources :tasks, only: :index
  end
  resources :users, only: :index
end

class TestBaseController < ActionController::Base
  include RansackMemory::Concern
  before_action :save_and_load_filters

  def index
    render json: { q: params[:q], page: params[:page], per_page: params[:per_page],
                   cancel_filter: params[:cancel_filter] }
  end
end

class ProjectsController < TestBaseController
  alias archive index
  alias shared index

  def clear
    clear_sessions
    render json: { keys: session.keys }
  end

  def keys
    render json: { keys: session.keys }
  end

  def link
    render inline: "<%= clear_filter title: 'Reset', class: 'btn', data: { confirm: 'Sure?' } %>"
  end

  private

  def set_session_key_identifier
    'projects_index_html' if action_name == 'shared'
  end
end

class UsersController < TestBaseController; end
class TasksController < TestBaseController; end

require 'rails/test_help'
