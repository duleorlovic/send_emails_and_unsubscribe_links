# https://github.com/duleorlovic/rails_helpers_and_const/blob/main/config/initializers/result_and_error.rb
class Result
  attr_accessor :message, :data

  # Use this to class to return results from service:
  #   return Result.new 'Next task created', next_task: next_task
  # and use in controller:
  #   result.data[:next_task] if result.success?
  #
  # Note when iterating a huge objects, use `next_task.id` so Ruby Garbage
  # Collector can clear all temp objects from the service run
  # If you return some object which is not basic, it can not safely clear all
  # temp objects
  def initialize(message, data = {})
    @message = message
    @data = OpenStruct.new data
  end

  def success?
    true
  end
end

class Error < Result
  def success?
    false
  end
end
