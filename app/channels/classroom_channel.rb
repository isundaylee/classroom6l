# Be sure to restart your server when you modify this file. Action Cable runs in an EventMachine loop that does not support auto reloading.
class ClassroomChannel < ApplicationCable::Channel
  def subscribed
    classroom_id = params['classroom_id'].to_i
    username = params['username'].strip

    stream_from "classroom_#{classroom_id}"

    Classroom.find(classroom_id).attendance_add(username)
  end

  def unsubscribed
    classroom_id = params['classroom_id'].to_i
    username = params['username'].strip

    Classroom.find(classroom_id).attendance_remove(username)
  end

  def run(data)
    classroom_id = params['classroom_id'].to_i
    RunCodeJob.perform_later(classroom_id, Classroom.find(classroom_id).code)
  end

  def submit_patches(data)
    classroom_id = params['classroom_id'].to_i
    client_id = params['client_id']
    classroom = Classroom.find(classroom_id)

    data['patches'].each do |patchText|
      puts '[DBG] ' + patchText.inspect

      result = {
        type: 'submit_patch_result',
        payload: {
          client_id: client_id
        }
      }

      success = classroom.apply_patch(patchText)

      if success
        result[:payload][:success] = true
        result[:payload][:patch] = patchText
      else
        result[:payload][:success] = false
      end

      ActionCable.server.broadcast "classroom_#{classroom_id}", result
    end
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

  def query_attendance
    classroom_id = params['classroom_id'].to_i
    classroom = Classroom.find(classroom_id)

    ActionCable.server.broadcast "classroom_#{classroom_id}", {
      type: 'query_attendance_result',
      payload: {
        attendance: classroom.attendance_get
      }
    }
  end

  def query_ping(data)
    classroom_id = params['classroom_id'].to_i
    client_id = params['client_id']
    sequence = data['sequence'].to_i

    ActionCable.server.broadcast "classroom_#{classroom_id}", {
      type: 'query_ping_result',
      payload: {
        sequence: sequence,
        client_id: client_id
      }
    }
  end

  def ping(data)
    classroom_id = params['classroom_id'].to_i
    client_id = params['client_id']
    seq = data['seq'].to_i

    ActionCable.server.broadcast "classroom_#{classroom_id}", {
      success: true, 
      client_id: client_id, 
      seq: seq, 
      payload: {}
    }
  end
end
