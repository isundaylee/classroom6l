# Be sure to restart your server when you modify this file. Action Cable runs in an EventMachine loop that does not support auto reloading.
class ClassroomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "classroom_#{params['classroom_id']}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def run(data)
    classroom_id = params['classroom_id'].to_i
    RunCodeJob.perform_later(classroom_id, Classroom.find(classroom_id).code)
  end

  def submit_patch(data)
    classroom_id = params['classroom_id'].to_i
    client_id = params['client_id']
    ChangeCodeJob.perform_later(classroom_id, client_id, data['patch'])
  end

  def revert(data)
    classroom_id = params['classroom_id'].to_i
    classroom = Classroom.find(classroom_id)
    client_id = params['client_id']

    ActionCable.server.broadcast "classroom_#{classroom_id}", {
      type: 'revert_result',
      payload: {
        code: classroom.code
      }
    }
  end
end
