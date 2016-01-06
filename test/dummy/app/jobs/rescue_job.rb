class RescueJob < ApplicationJob
  JobError = Class.new(StandardError)

  max_retry 3

  rescue_from JobError do
    retry_job wait: 1.hour unless retries_exhausted?
  end

  def perform
    raise JobError
  end
end
