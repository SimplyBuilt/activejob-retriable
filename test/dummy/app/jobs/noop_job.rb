class NoopJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    # Do nothing later
  end
end
