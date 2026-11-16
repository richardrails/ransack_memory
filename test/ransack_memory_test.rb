require 'test_helper'

class RansackMemoryTest < ActionDispatch::IntegrationTest
  setup do
    @original_config = RansackMemory::Core.config
    RansackMemory::Core.config = { param: :q, session_key_format: '%controller_name%_%action_name%_%request_format%' }
  end

  teardown { RansackMemory::Core.config = @original_config }

  def json
    JSON.parse(response.body)
  end

  test 'saves the filter and loads it on the next request' do
    get '/projects', params: { q: { name_cont: 'abc' } }
    assert_equal({ 'name_cont' => 'abc' }, json['q'])

    get '/projects'
    assert_equal({ 'name_cont' => 'abc' }, json['q'])
  end

  test 'filter is not shared with another action or controller' do
    get '/projects', params: { q: { name_cont: 'abc' } }

    get '/projects/archive'
    assert_nil json['q']
    get '/users'
    assert_nil json['q']
  end

  test 'filter is not shared between formats' do
    get '/projects', params: { q: { name_cont: 'abc' } }
    get '/projects.json'
    assert_nil json['q']
  end

  test 'saves and loads page and per page' do
    get '/projects', params: { page: '3', per_page: '50' }
    get '/projects', params: { page: '3' }
    get '/projects'
    assert_equal '3', json['page']
    assert_equal '50', json['per_page']
  end

  test 'page is reset when the filter changes' do
    get '/projects', params: { q: { name_cont: 'abc' } }
    get '/projects', params: { page: '5' }
    assert_equal '5', json['page']

    get '/projects', params: { q: { name_cont: 'xyz' } }
    assert_nil json['page']
    get '/projects'
    assert_nil json['page']
    assert_equal({ 'name_cont' => 'xyz' }, json['q'])
  end

  test 'page is kept when the same filter is sent again with pagination link' do
    get '/projects', params: { q: { name_cont: 'abc' } }
    get '/projects', params: { q: { name_cont: 'abc' }, page: '2' }
    assert_equal '2', json['page']
    get '/projects', params: { q: { name_cont: 'abc' } }
    assert_equal '2', json['page']
  end

  # regression: one global "last filter" was shared by the whole application
  test 'page is reset even if the new filter equals the last filter used in another action' do
    get '/projects', params: { q: { name_cont: 'abc' } }
    get '/projects', params: { page: '5' }
    get '/users', params: { q: { name_cont: 'xyz' } }

    get '/projects', params: { q: { name_cont: 'xyz' } }
    assert_nil json['page'], 'stale page number would show an empty list'
  end

  # regression: visiting another list threw away the saved page
  test 'page is remembered after visiting another action' do
    get '/projects', params: { q: { name_cont: 'abc' } }
    get '/projects', params: { page: '5' }
    get '/users', params: { q: { name_cont: 'xyz' } }

    get '/projects'
    assert_equal '5', json['page']
    assert_equal({ 'name_cont' => 'abc' }, json['q'])
  end

  test 'page is reset when per page changes' do
    get '/projects', params: { per_page: '10' }
    get '/projects', params: { page: '8' }
    get '/projects', params: { per_page: '100' }
    assert_nil json['page']
    assert_equal '100', json['per_page']

    get '/projects', params: { per_page: '100', page: '2' }
    assert_equal '2', json['page']
  end

  test 'cancel filter clears everything and is removed from params' do
    get '/projects', params: { q: { name_cont: 'abc' }, per_page: '50' }
    get '/projects', params: { page: '2' }

    get '/projects', params: { cancel_filter: 'true' }
    assert_nil json['q']
    assert_nil json['page']
    assert_nil json['per_page']
    assert_nil json['cancel_filter']

    get '/projects'
    assert_nil json['q']
  end

  test 'cancel filter does not leave empty keys in the session' do
    get '/projects', params: { q: { name_cont: 'abc' }, page: '2' }
    get '/projects', params: { cancel_filter: 'true' }
    get '/projects/keys'
    assert_empty(json['keys'].grep(/ranmemory/))
  end

  test 'cancel filter with a new filter stores the new filter' do
    get '/projects', params: { q: { name_cont: 'abc' } }
    get '/projects', params: { cancel_filter: 'true', q: { name_cont: 'new' } }
    get '/projects'
    assert_equal({ 'name_cont' => 'new' }, json['q'])
  end

  test 'submitting a blank form replaces the saved filter' do
    get '/projects', params: { q: { name_cont: 'abc' } }
    get '/projects', params: { q: { name_cont: '' } }
    get '/projects'
    assert_equal({ 'name_cont' => '' }, json['q'])
  end

  test 'non hash search param does not raise and is not stored' do
    get '/projects', params: { q: { name_cont: 'abc' } }

    get '/projects', params: { q: 'plain text' }
    assert_response :success
    assert_equal 'plain text', json['q']

    get '/projects'
    assert_equal({ 'name_cont' => 'abc' }, json['q'])
  end

  test 'nested and array filter values survive the session round trip' do
    filter = { 'status_in' => %w[a b], 'g' => { '0' => { 'm' => 'or', 'name_cont' => 'x' } } }
    get '/projects', params: { q: filter }
    get '/projects', params: { page: '2' }
    get '/projects', params: { q: filter }
    assert_equal filter, json['q']
    assert_equal '2', json['page'], 'the same filter must not be seen as changed'
  end

  test 'set_session_key_identifier loads the filter of another action and may be private' do
    get '/projects', params: { q: { name_cont: 'abc' } }
    get '/projects/shared'
    assert_equal({ 'name_cont' => 'abc' }, json['q'])
  end

  test 'legacy global last_q_params key is removed' do
    get '/projects', params: { q: { name_cont: 'abc' } }
    get '/projects/keys'
    assert_not_includes json['keys'], 'last_q_params'
  end

  test 'clear_sessions removes all saved filters' do
    get '/projects', params: { q: { name_cont: 'abc' }, per_page: '5' }
    get '/users', params: { q: { name_cont: 'abc' } }
    get '/projects/clear'
    assert_empty(json['keys'].grep(/ranmemory/))
    get '/projects'
    assert_nil json['q']
  end

  test 'turbo frame variable separates filters per frame' do
    RansackMemory::Core.config = { param: :q, session_key_format: '%controller_name%_%action_name%_%turbo_frame%' }
    get '/projects', params: { q: { name_cont: 'frame' } }, headers: { 'Turbo-Frame' => 'list' }
    get '/projects'
    assert_nil json['q']
    get '/projects', headers: { 'Turbo-Frame' => 'list' }
    assert_equal({ 'name_cont' => 'frame' }, json['q'])
  end

  test 'path_params variable separates filters of nested resources' do
    RansackMemory::Core.config = { param: :q, session_key_format: '%controller_name%_%action_name%_%path_params%' }
    get '/projects/1/tasks', params: { q: { name_cont: 'one' }, page: '4' }
    get '/projects/1/tasks', params: { page: '4' }

    get '/projects/2/tasks'
    assert_nil json['q']
    assert_nil json['page']

    get '/projects/1/tasks'
    assert_equal({ 'name_cont' => 'one' }, json['q'])
    assert_equal '4', json['page']
  end

  test 'without path_params nested resources share the filter (default)' do
    get '/projects/1/tasks', params: { q: { name_cont: 'one' } }
    get '/projects/2/tasks'
    assert_equal({ 'name_cont' => 'one' }, json['q'])
  end

  test 'header value is inserted literally and unknown variables are kept' do
    RansackMemory::Core.config = { param: :q, session_key_format: '%turbo_frame%_%unknown%' }
    evil = '\\0%action_name%' + ('x' * 500)
    get '/projects', params: { q: { name_cont: 'abc' } }, headers: { 'Turbo-Frame' => evil }
    assert_response :success
    get '/projects/keys'
    key = json['keys'].grep(/ranmemory/).first
    assert key.start_with?('ranmemory_\\0%action_name%xxx')
    assert key.end_with?('_%unknown%')
    assert_operator key.length, :<, 150
  end

  test 'works with missing configuration' do
    RansackMemory::Core.config = {}
    get '/projects', params: { q: { name_cont: 'abc' } }
    get '/projects'
    assert_equal({ 'name_cont' => 'abc' }, json['q'])
  end

  test 'custom param name' do
    RansackMemory::Core.config = { param: :search }
    get '/projects', params: { search: { name_cont: 'abc' } }
    get '/projects/keys'
    assert_equal 1, json['keys'].grep(/ranmemory/).size
  end

  test 'clear filter link disables turbo prefetch and keeps custom attributes' do
    get '/projects/link', params: { q: { name_cont: 'abc' } }
    assert_includes response.body, 'cancel_filter=true'
    assert_includes response.body, 'data-turbo-prefetch="false"'
    assert_includes response.body, 'data-confirm="Sure?"'
    assert_includes response.body, 'class="btn"'
    assert_includes response.body, 'Reset'
  end
end
