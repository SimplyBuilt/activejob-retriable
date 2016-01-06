require 'active_job/retriable'

module ActiveJob
  extend ActiveSupport::Autoload

  autoload :Retriable
end
