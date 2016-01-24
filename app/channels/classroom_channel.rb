# Be sure to restart your server when you modify this file. Action Cable runs in an EventMachine loop that does not support auto reloading.
class ClassroomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "classroom_#{params['classroom_id']}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def run(data)
    classroom_id = data['classroom_id'].to_i
    RunCodeJob.perform_later(classroom_id, Classroom.find(classroom_id).code)
  end

  def submit_change(data)
    classroom_id = data['classroom_id'].to_i
    ChangeCodeJob.perform_later(classroom_id, data['previous'], data['updated'])
  end
end
