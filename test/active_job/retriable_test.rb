require 'test_helper'

class ActiveJob::RetriableTest < ActiveSupport::TestCase
  attr_reader :adapter

  def before_setup
    super # setup ActiveJob::TestHelper

    # Initialize our custom adapter
    @adapter = ActiveJob::QueueAdapters::RetriableTestAdapter.new

    # Set to new Adapter now
    ActiveJob::Base.queue_adapter = @adapter
  end

  test 'failed job is retried until DEFAULT_MAX' do
    assert_performed_jobs 25 do
      RaiseJob.perform_later
    end
  end

  test 'failed job is retried until specified max_retry' do
    assert_performed_jobs 10 do
      MaxJob.perform_later
    end
  end

  test 'failed job with custom rescue_from is retried' do
    assert_performed_jobs 3 do
      RescueJob.perform_later
    end
  end

  test 'failed job with custom rescue_from uses custom retry wait time' do
    perform_enqueued_jobs do
      RescueJob.perform_later
    end

    # Two jobs are performed with +at+ keys
    assert_equal 2, adapter.performed_jobs.map { |job|
      job['at']
    }.compact.size
  end
end
