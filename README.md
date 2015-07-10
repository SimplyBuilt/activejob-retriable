# ActiveJob::Retriable ![Build Status](https://travis-ci.org/SimplyBuilt/activejob-retriable.svg)

Automatically retry failed jobs with an exponential back-off.

This gem is aims to mimic most of the functionality of Sidekiq's
RetryJobs middleware.

## Support

Backends that support the `enqueued_at` method are supported. A
Runtime exeception is raised if this concern is included in a job with
an unsupported backend.

Test gem has only been tested with the Sidekiq backend. Please submit
pull-requests and issues for backends that are not functioning properly.

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

3. If you're using ActiveJob assertions in controllers or elsewhere, be
   sure to include the test helper concern there as well

4. *Optionally* add a setup and teardown block to toggle on
   `reraise_when_retry_exhausted`

        setup do
          ActiveJob::Retriable.reraise_when_retry_exhausted = true
        end

        teardown do
          ActiveJob::Retriable.reraise_when_retry_exhausted = false
        end

## LICENSE

This project rocks and uses MIT-LICENSE.
