require 'test_helper'

class ActiveJob::Retriable::TestAdapterTest < ActiveJob::TestCase
  test 'enqueued_jobs have job defined' do
    NoopJob.perform_later

    assert_equal NoopJob, enqueued_jobs.first[:job]
  end

  test 'performed_jobs has job defined' do
    perform_enqueued_jobs do
      NoopJob.perform_later
    end

    assert_equal NoopJob, performed_jobs.first[:job]
  end

  test 'enqueued_jobs have args defined' do
    NoopJob.perform_later

    assert_equal [], enqueued_jobs.first[:args]
  end

  test 'performed_jobs has args defined' do
    perform_enqueued_jobs do
      NoopJob.perform_later
    end

    assert_equal [], performed_jobs.first[:args]
  end

  test 'enqueued_jobs have queue defined' do
    NoopJob.perform_later

    assert_equal 'default', enqueued_jobs.first[:queue]
  end

  test 'performed_jobs has queue defined' do
    perform_enqueued_jobs do
      NoopJob.perform_later
    end

    assert_equal 'default', performed_jobs.first[:queue]
  end

  test 'enqueued jobs with wait have at defined' do
    NoopJob.set(wait: 1.hour).perform_later

    refute_nil enqueued_jobs.first[:at]
  end

  test 'performed jobs with wait have at defined' do
    perform_enqueued_jobs do
      NoopJob.set(wait: 1.hour).perform_later
    end

    refute_nil performed_jobs.first[:at]
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

  test 'test adapter handles assert_enqueued_with at option' do
    assert_enqueued_with at: Date.tomorrow.noon do
      NoopJob.set(wait_until: Date.tomorrow.noon).perform_later
    end
  end

  test 'test adapter handles assert_enqueued_with queue option' do
    assert_enqueued_with queue: 'default' do
      NoopJob.perform_later
    end
  end

  test 'test adapter handles assert_performed_jobs filtering' do
    assert_enqueued_jobs 1, only: NoopJob do
      NoopJob.perform_later
    end
  end
end
