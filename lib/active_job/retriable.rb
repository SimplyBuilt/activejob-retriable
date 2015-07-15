require 'active_job/retriable/version'

module ActiveJob
  module Retriable
    extend ActiveSupport::Concern

    BASE_TAG = self.name
    DEFAULT_FACTOR = 4
    DEFAULT_MAX    = 25

    @reraise_when_retry_exhausted = false

    def self.reraise_when_retry_exhausted=(option)
      @reraise_when_retry_exhausted = !!option
    end

    def self.reraise_when_retry_exhausted?
      @reraise_when_retry_exhausted
    end

    included do
      raise 'Adapter does not support enqueue_at method' unless self.queue_adapter.respond_to?(:enqueue_at)

      delegate :reraise_when_retry_exhausted?, to: 'ActiveJob::Retriable'

      # TODO think about how to handle ActiveJob::DeserializationError
      rescue_from Exception do |ex|
        tags = "[#{BASE_TAG}] [#{self.class.name}] [#{job_id}]"

        # NOTE we avoid using the tag_logger method so we don't end up
        # with recursively tagged logs in when in test mode
        if retries_exhausted?
          logger.info "#{tags} Retries exhauseted at #{retry_attempt} attempts"

          raise if reraise_when_retry_exhausted?
        else
          logger.warn "#{tags} Retrying due to #{ex.message} on #{ex.backtrace.try(:first)} (attempted #{retry_attempt})"

          retry_job wait: retry_delay
        end
      end

      before_perform do
        self.retry_attempt += 1
      end
    end

    module ClassMethods
      attr_accessor :retry_max

      def max_retry(max)
        self.retry_max = max || 0
      end
    end

    attr_writer :retry_attempt

    def retries_exhausted?
      retry_attempt >= (self.class.retry_max || DEFAULT_MAX)
    end

    def retry_delay
      1
      #(retry_attempt ** DEFAULT_FACTOR) + (rand(30) * retry_attempt)
    end

    def retry_attempt
      @retry_attempt ||= 0
    end

    def serialize
      super.update 'retry_attempt' => retry_attempt
    end

    # Rails 5 deserialization approach
    # NOTE the conditional will be removed with Rails 5
    def deserialize(job_data)
      super job_data

      self.retry_attempt = job_data['retry_attempt']
    end if instance_methods.include?(:deserialize)
  end
end
