$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "active_job/retriable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "activejob-retriable"
  s.version     = ActiveJob::Retriable::VERSION
  s.authors     = ["Michael Coyne"]
  s.email       = ["mikeycgto@gmail.com"]
  s.homepage    = "activejob-retriable.onsimplybuilt.com"
  s.summary     = "Automatically retries jobs"
  s.description = "This gem aims to mimic most of the functionality of Sidekiq's RetryJobs middleware."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "activejob", '~> 4.2.3'

  s.add_development_dependency "rails", "~> 4.2.3"
  s.add_development_dependency "sqlite3"
end
