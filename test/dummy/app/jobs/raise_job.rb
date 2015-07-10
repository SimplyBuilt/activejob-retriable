class RaiseJob < ActiveJob::Base
  include ActiveJob::Retriable

  queue_as :default

  def perform
    raise StandardError
  end
end
