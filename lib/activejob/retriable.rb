require 'active_job/retriable'

module ActiveJob
  extend ActiveSupport::Autoload

  autoload :Retriable
end

# ActiveJob deserialization monkey patch
# NOTE this will be removed once Rails 5 is released
unless ActiveJob::Base.instance_methods.include?(:deserialize)
  module ActiveJob
    class Base
      def self.deserialize(job_data)
        job               = super(job_data)
        job.retry_attempt = job_data['retry_attempt'] if job.respond_to?(:retry_attempt=)
        job
      end
    end
  end
end
