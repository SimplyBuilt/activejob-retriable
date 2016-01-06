module ActiveJob
  module Retriable
    class TestAdapter < ActiveJob::QueueAdapters::TestAdapter
      def enqueue_or_perform(perform, job, job_data)
        if perform
          performed_jobs << job_data

          # Use perform_now instead of execute so all callbacks are invoked (ie: before_perform)
          ActiveJob::Base.perform_now job

        else
          enqueued_jobs << job_data
        end
      end
    end
  end
end
