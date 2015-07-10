class MaxJob < ActiveJob::Base
  include ActiveJob::Retriable

  queue_as :default
  max_retry 10

  def perform
    raise StandardError
  end
end
