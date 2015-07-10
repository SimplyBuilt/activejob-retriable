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

class ActiveSupport::TestCase
  include ActiveJob::TestHelper
end

# Use our TestAdapter since it is unaware of custom
# serialization
module ActiveJob::QueueAdapters
  class RetriableTestAdapter < TestAdapter
    def enqueue(job)
      process_job_and_data job, job.serialize
    end

    def enqueue_at(job, timestamp)
      process_job_and_data job, job.serialize.update('at' => timestamp)
    end

    def process_job_and_data(job, job_data)
      if perform_enqueued_jobs
        ActiveJob::Base.perform_now job

        performed_jobs << job_data
      else
        enqueued_jobs << job_data
      end
    end
  end
end
