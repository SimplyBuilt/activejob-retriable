class RaiseJob < ApplicationJob
  queue_as :default

  def perform
    raise StandardError
  end
end
