$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ransack_memory/version"

Gem::Specification.new do |s|
  s.name               = "ransack_memory"
  s.version            = RansackMemory::VERSION
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9.3'

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Richard Lapiš"]
  s.date = %q{2018-06-25}
  s.description = %q{Automatically save and load ransack's filtered params into session}
  s.email = %q{richard.lapis@gmail.com}
  s.files = `git ls-files`.split("\n")
  s.test_files = []
  s.homepage = %q{https://github.com/richardrails/ransack_memory}
  s.files = Dir["{app,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Automatically save and load ransack's filtered params into session}
  s.license = 'MIT'

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end