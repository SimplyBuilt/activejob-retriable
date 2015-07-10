require 'active_job/retriable/version'

module ActiveJob
  module Retriable
    extend ActiveSupport::Concern

    DEFAULT_MAX    = 25
    DEFAULT_FACTOR = 4

    included do
      # TODO think about how to handle ActiveJob::DeserializationError
      rescue_from Exception do |ex|
        tag_logger self.class.name, job_id do
          if retries_exhausted?
            logger.info "Retries exhauseted at #{retry_attempt}"

          else
            logger.warn "Retrying due to #{ex.message} on #{ex.backtrace.try(:first)}"

            retry_job wait: retry_delay unless retries_exhausted?
          end
        end
      end

      before_perform do
        @retry_attempt += 1
      end
    end

    module ClassMethods
      attr_accessor :retry_max

      def max_retry(max)
        self.retry_max = max
      end
    end

    def retries_exhausted?
      retry_attempt > (self.class.retry_max || DEFAULT_MAX)
    end

    def retry_delay
      (retry_attempt ** DEFAULT_FACTOR) + (rand(30) * retry_attempt)
    end

    def retry_attempt
      @retry_attempt ||= 1
    end

    def serialize
      super.update 'retry_attempt' => retry_attempt
    end

    def deserialize(job_data)
      super job_data

      @retry_attempt = job_data['retry_attempt']
    end
  end
end
