class ApplicationJob < ActiveJob::Base
  include ActiveJob::Retriable
end
