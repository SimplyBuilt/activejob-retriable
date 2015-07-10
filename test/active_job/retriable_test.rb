require 'test_helper'

class ActiveJob::RetriableTest < ActiveJob::TestCase
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
    assert_equal 2, performed_jobs.map { |job| job['at'] }.compact.size
  end

  test 'raises exception when include in an ActiveJob with an adapter that does not support an enqueue_at method' do
    assert_raises RuntimeError do
      Class.new(ActiveJob::Base) do
        self.queue_adapter = Class.new do
          def enqueue
          end
        end.new

        include ActiveJob::Retriable
      end
    end
  end
end
