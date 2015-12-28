module ActiveJob
  module Retriable
    class TestAdapter < ActiveJob::QueueAdapters::TestAdapter
      # Custom TestAdapter since the default TestAdapter does not use
      # serialization and breaks encoding of retry_attempts
      def enqueue(job)
        process_job_and_data job, job.serialize
      end

      def enqueue_at(job, timestamp)
        process_job_and_data job, job.serialize.update('at' => timestamp)
      end

      def process_job_and_data(job, job_data)
        job_data = job_data.with_indifferent_access

        # TODO Why do we need job for assert methods and class for filtering?
        # TODO Use job_to_hash in Rails5
        job_data.update({
          class: job.class,
          job: job.class,
          args: job.arguments,
          queue: job.queue_name
        })

        if perform_enqueued_jobs
          # Use perform_now instead of execute so all callbacks are invoked (ie: before_perform)
          ActiveJob::Base.perform_now job

          performed_jobs << job_data
        else
          enqueued_jobs << job_data
        end
      end
    end
  end
end
