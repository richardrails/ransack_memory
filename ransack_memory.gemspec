$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ransack_memory/version"

Gem::Specification.new do |s|
  s.name        = "ransack_memory"
  s.version     = RansackMemory::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Richard Lapiš"]
  s.email       = "richard.lapis@gmail.com"
  s.homepage    = "https://github.com/richardrails/ransack_memory"
  s.summary     = "Automatically save and load ransack's filtered params into session"
  s.description = "Remembers Ransack search params, page number and per page value in the Rails session for each controller action and loads them back on the next visit."
  s.license     = "MIT"

  s.required_ruby_version = ">= 2.5"

  s.metadata = {
    "source_code_uri" => s.homepage,
    "bug_tracker_uri" => "#{s.homepage}/issues"
  }

  s.files = Dir["{app,lib}/**/*", "MIT-LICENCE", "LICENCE", "README.md"]
  s.require_paths = ["lib"]
end
