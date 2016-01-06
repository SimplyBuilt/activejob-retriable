class CallbacksJob < ApplicationJob
  queue_as :default

  def self.callback_results
    @_callback_results ||= []
  end

  def self.reset_results!
    @_callback_results = nil
  end

  before_exception do
    self.class.callback_results << current_exception
  end

  after_exception do
    self.class.callback_results << current_exception
  end

  around_exception do
    self.class.callback_results << current_exception
  end

  def perform
    raise StandardError, 'Callbacks test'
  end
end
