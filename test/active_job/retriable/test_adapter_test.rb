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
end
