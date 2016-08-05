# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../../test/dummy/config/environment.rb',  __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path('../../test/dummy/db/migrate', __FILE__)]
require 'rails/test_help'

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path('../fixtures', __FILE__)
  ActiveSupport::TestCase.fixtures :all
end

require 'active_job/retriable/test_helper'

class ActiveJob::TestCase
  include ActiveJob::Retriable::TestHelper

  def capture_stderr
    begin
      original_stderr = $stderr

      $stderr = StringIO.new('', 'w')
      yield
      $stderr.string
    ensure
      $stderr = original_stderr
    end
  end
end
