require 'active_job/retriable/test_adapater'

module ActiveJob
  module Retriable
    module TestHelper
      extend ActiveSupport::Concern

      included do
        include ActiveJob::TestHelper

        def before_setup
          super # setup ActiveJob::TestHelper

          # Initialize our custom adapter
          retriable_adapter = ActiveJob::Retriable::TestAdapter.new

          # This is from active_job/test_helper
          ActiveJob::Base.queue_adapter = retriable_adapter
          ActiveJob::Base.subclasses.each do |klass|
            # only override explicitly set adapters, a quirk of `class_attribute`
            if klass.singleton_class.public_instance_methods(false).include?(:_queue_adapter)
              klass.queue_adapter = retriable_adapter
            end
          end

          clear_enqueued_jobs
          clear_performed_jobs
        end
      end

      # NOTE we do not need our own after_teardown since the
      # after_teardown in ActiveJob::TestHelper resets all the original
      # adapters
    end
  end
end