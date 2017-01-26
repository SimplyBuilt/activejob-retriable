ActiveJob::Retriable
====================

[![Build Status](https://travis-ci.org/SimplyBuilt/activejob-retriable.svg)](https://travis-ci.org/SimplyBuilt/activejob-retriable)
[![Gem Version](https://badge.fury.io/rb/activejob-retriable.svg)](https://rubygems.org/gems/activejob-retriable)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)

Automatically retry failed ActiveJobs with an exponential back-off.

This gem aims to mimic most of the functionality of Sidekiq's
RetryJobs middleware but operates at the ActiveJob abstract
layer.

## Installation

To install the gem, add the following to your Gemfile:

    gem "activejob-retriable"

If you're using Rails 5, use the branch master off Github for support. Once the first stable release of
Rails 5 is out we will push a 5.0 version of gem.

    gem "activejob-retriable", github: "SimplyBuilt/activejob-retriable"

## Usage

The simplest way to use this gem is to include the following your `ApplicationJob` class

    class ApplicationJob < ActiveJob::Base
      include ActiveJob::Retriable
    end

A `max_retry` class method as well as before, after and around exception callbacks
will now be available to all your Jobs. For example:

    class MyJob < ApplicationJob
      max_retry 12

      after_exception do
        # Record exeception to our fictitious error service
        ErrorNotify.dispatch current_exception
      end
    end

## Support

Backends that support the retrying of jobs are supported. A Runtime
exception is raised if this concern is included in a job class
with an unsupported backend.

The gem has only been tested with the Sidekiq backend. Please submit
pull-requests and issues for backends that do not function properly.

## rescue_from Blocks With retry_job

The motivation of this gem is to play nicely with existing `rescue_from`
blocks within your job classes. If a `rescue_from` block makes calls to
`retry_job` is it probably best to call this method if and only if
`retries_exhausted?` is not `true`. Otherwise, your jobs may be retried
indefinitely! See this [test job
class](https://github.com/SimplyBuilt/activejob-retriable/blob/master/test/dummy/app/jobs/rescue_job.rb#L8)
for an example.

## Exception Callbacks

Much like `ActiveJob` itself, retriable introduces some callbacks for
exception handling. Your job class can define `before_exception`,
`after_exception` and `around_exception` callbacks.

Retriable will also set the value of `current_exception` to the actual
exception. This way, direct access to the exception is possible from
within a callback. This may be useful for error reporting and other
needs.

## Retriable with ActionMailer

If you want `ActionMailer` delivery jobs to use `Retriable`, you have to
reopen the `ActionMailer::DeliveryJob` class and manually include the
concern. For example:

    module ActionMailer
      class DeliveryJob
        include ActiveJob::Retriable
      end
    end

It is recommended to do this via an initializer. We're open to
suggestions on how to improve this aspect of `Retriable` though!

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
   `reraise_when_retry_exhausted`, `print_exceptions_to_stderr` and
`print_exception_backtraces_to_stderr`. These features are useful when
testing and debugging Active Jobs that raise exceptions or have syntax
errors.

        setup do
          ActiveJob::Retriable.reraise_when_retry_exhausted = true
          ActiveJob::Retriable.print_exceptions_to_stderr   = true

          # Or with a full backtrace...
          # ActiveJob::Retriable.print_exceptions_to_stderr   = :backtrace
        end

        teardown do
          ActiveJob::Retriable.reraise_when_retry_exhausted = false
          ActiveJob::Retriable.print_exceptions_to_stderr   = false
        end

Additionally, if you have jobs being enqueued in your `setup` blocks, it
is highly recommended that you move that functionality to an
`after_setup` method. This is due to how the default `TestHelper` works
and may change in the future.

## Adapter Notes & Tips

- With **Sidekiq**, we highly encourage that you remove the RetryJobs
  middleware. This can be done in an initializer with the following:

        Sidekiq.configure_server do |config|
          config.server_middleware.remove Sidekiq::Middleware::Server::RetryJobs
        end


## LICENSE

This project rocks and uses MIT-LICENSE.
