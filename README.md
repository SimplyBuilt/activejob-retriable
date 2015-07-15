# ActiveJob::Retriable ![Build Status](https://travis-ci.org/SimplyBuilt/activejob-retriable.svg)

Automatically retry failed jobs with an exponential back-off.

This gem is aims to mimic most of the functionality of Sidekiq's
RetryJobs middleware.

## Support

Backends that support the retrying jobs are supported. A Runtime
exeception is raised if this concern is included in a job with
an unsupported backend.

The gem has only been tested with the Sidekiq backend. Please submit
pull-requests and issues for backends that are not functioning properly.

## Rescue From Blocks

The motivation of this gem is to play nicely with existing `rescue_from`
blocks within your job classes. If your `rescue_from` blocks call
`retry_job` is it probably best to call this method if and only if
`retries_exhausted?` is not `true`. Otherwise, your jobs may be retried
indefinitely! See this [test job
class](https://github.com/SimplyBuilt/activejob-retriable/blob/master/test/dummy/app/jobs/rescue_job.rb#L8)
for an example.

## Advanced Usage

It is possible to overload or redefine both `retry_delay` and
`retries_exhausted?` to include custom logic. This means it is easy to
implement different back-off strategies as well as more advanced
exhausted logic.

Feel free to open PR's with more advanced examples!

## Testing

The default `ActiveJob::QueueAdapters::TestAdapter` does not call
serialize and deserialize as one may expect. Thus, `retry_attempts` are
not properly tracked and "infinite performs" occur when an exception is
raised. Therefore, we provided a new subclass to TestAdapter named
`ActiveJob::Retriable::TestAdapter`. To use this adapter please do the
following:

1. Include the `ActiveJob::Retriable::TestHelper` in your `test_helper.rb`

        require 'active_job/retriable/test_helper'

2. Reopen `ActiveJob::TestCase` and include the helper

        class ActiveJob::TestCase
          include ActiveJob::Retriable::TestHelper
        end

   Alternatively, you can just include the helper on a test-by-test
basis.

3. If you're using ActiveJob assertions in controllers or elsewhere, be
   sure to include the test helper concern there as well!

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
