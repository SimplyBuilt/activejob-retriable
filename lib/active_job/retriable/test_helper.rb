require 'active_job/retriable/test_adapater'

module ActiveJob
  module Retriable
    module TestHelper
      include ActiveJob::TestHelper

      def queue_adapter_for_test
        ActiveJob::Retriable::TestAdapter.new
      end
    end
  end
end
