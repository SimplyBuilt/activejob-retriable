require 'test_helper'

class ActiveJob::Retriable::TestAdapterTest < ActiveJob::TestCase
  test 'enqueued_jobs have class defined' do
    NoopJob.perform_later

    assert_equal NoopJob, enqueued_jobs.first['class']
  end

  test 'performed_jobs has class defined' do
    perform_enqueued_jobs do
      NoopJob.perform_later
    end

    assert_equal NoopJob, performed_jobs.first['class']
  end

  test 'enqueued jobs with wait have at defined' do
    NoopJob.set(wait: 1.hour).perform_later

    refute_nil enqueued_jobs.first['at']
  end

  test 'performed jobs with wait have at defined' do
    perform_enqueued_jobs do
      NoopJob.set(wait: 1.hour).perform_later
    end

    refute_nil performed_jobs.first['at']
  end

  test 'enqueued jobs have indifferent access' do
    NoopJob.perform_later

    assert_instance_of ActiveSupport::HashWithIndifferentAccess, enqueued_jobs.first
  end

  test 'performed jobs have indifferent access' do
    perform_enqueued_jobs do
      NoopJob.perform_later
    end

    assert_instance_of ActiveSupport::HashWithIndifferentAccess, performed_jobs.first
  end

  test 'test adapter handles assert_enqueued_with job option' do
    assert_enqueued_with job: NoopJob do
      NoopJob.perform_later
    end
  end

  test 'test adapter handles assert_enqueued_with args option' do
    assert_enqueued_with args: [] do
      NoopJob.perform_later
    end
  end

  # TODO This won't pass until Rails 5
  #test 'test adapter handles assert_enqueued_with at option' do
    #puts serialize_args_for_assertion(at: Date.tomorrow.noon)

    #assert_enqueued_with at: Date.tomorrow.noon do
      #NoopJob.set(wait_until: Date.tomorrow.noon).perform_later
    #end
  #end

  test 'test adapter handles assert_enqueued_with queue option' do
    assert_enqueued_with queue: 'default' do
      NoopJob.perform_later
    end
  end

  # TODO this won't pass till Rails 5
  #test 'test adapter handles assert_performed_jobs filtering' do
    #assert_enqueued_jobs 1, only: NoopJob do
      #NoopJob.perform_later
    #end
  #end

  test 'deserialize monkey patch sets retry_attempt' do
    job_data = { 'job_class' => 'RescueJob', 'retry_attempt' => 12 }
    job = RescueJob.deserialize(job_data)

    assert_equal 12, job.retry_attempt
  end
end
