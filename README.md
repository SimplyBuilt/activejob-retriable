# ActiveJob::Retriable

Automatically retry failed jobs with an exponential back-off.

This gem is aims to mimic most of the functionality of Sidekiq's
RetryJobs middleware.

## Testing

The default `ActiveJob::QueueAdapters::TestAdapter` does not call
serialize and deserialize as may expect. Thus, `retry_attempts` are not
properly tracked and "infinite performs" occur when an exception is
raised. Therefore, we provided a new subclass TestAdapter name
`ActiveJob::Retriable::TestAdapter`. To use this adapter please do the
following:

1. Include the `ActiveJob::Retriable::TestHelper` in your `test_helper.rb`

        require 'active_job/retriable/test_helper'

2. Reopen `ActiveJob::TestCase` and include the helper

        class ActiveJob::TestCase
          include ActiveJob::Retriable::TestHelper
        end

   Alternatively, you can just include the helper on a test-by-test
basis

3. *Optionally* add a setup and teardown block to toggle on
   `reraise_when_retry_exhausted`

        setup do
          ActiveJob::Retriable.reraise_when_retry_exhausted = true
        end

        teardown do
          ActiveJob::Retriable.reraise_when_retry_exhausted = false
        end

## LICENSE

This project rocks and uses MIT-LICENSE.
