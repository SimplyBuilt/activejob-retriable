class MaxJob < ApplicationJob
  queue_as :default
  max_retry 10

  def perform
    raise StandardError
  end
end
