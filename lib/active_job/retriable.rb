require 'active_job/retriable/version'

module ActiveJob
  module Retriable
    extend ActiveSupport::Concern
    include ActiveSupport::Callbacks

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
      raise 'Adapter does not support enqueue_at method' if self.queue_adapter.method(:enqueue_at).arity < 0

      delegate :reraise_when_retry_exhausted?, to: 'ActiveJob::Retriable'
      define_callbacks :exception

      log_tags = "[#{BASE_TAG}] [#{self.class.to_s}]"

      # TODO think about how to handle ActiveJob::DeserializationError
      rescue_from Exception do |ex|
        self.current_exception = ex

        # Avoid using the tag_logger method so we don't end up
        # with recursively tagged logs in when in test mode
        run_callbacks :exception do
          if retries_exhausted?
            logger.info "#{log_tags} [#{job_id}] Retries exhauseted at #{retry_attempt} attempts"

            raise ex if reraise_when_retry_exhausted?
          else
            logger.warn "#{log_tags} [#{job_id}] Retrying due to #{ex.class.name} #{ex.message} on #{ex.backtrace.try(:first)} (attempted #{retry_attempt})"

            retry_job wait: retry_delay
          end
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

      def before_exception(*filters, &blk)
        set_callback :exception, :before, *filters, &blk
      end

      def after_exception(*filters, &blk)
        set_callback :exception, :after, *filters, &blk
      end

      def around_exception(*filters, &blk)
        set_callback :exception, :around, *filters, &blk
      end
    end

    attr_writer :retry_attempt
    attr_accessor :current_exception

    def retries_exhausted?
      retry_attempt >= (self.class.retry_max || DEFAULT_MAX)
    end

    def retry_delay
      (retry_attempt ** DEFAULT_FACTOR) + (rand(30) * retry_attempt)
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
