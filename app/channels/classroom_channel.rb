# Be sure to restart your server when you modify this file. Action Cable runs in an EventMachine loop that does not support auto reloading.
class ClassroomChannel < ApplicationCable::Channel
  def subscribed
    @classroom_id = params['classroom_id'].to_i
    @classroom = Classroom.find(@classroom_id)
    @client_id = params['client_id']
    @username = params['username'].strip

    stream_from "classroom_#{@classroom_id}"

    @classroom.attendance_add(@username)
  end

  def unsubscribed
    @classroom.attendance_remove(@username)
  end

  def run(data)
    RunCodeJob.perform_later(@classroom_id, @classroom.code)
  end

  def sync(data)
    transmitResponse data['seq'].to_i, true, content: @classroom.code
  end

  def query_attendance(data)
    transmitResponse data['seq'].to_i, true, attendance: @classroom.attendance_get
  end

  def ping(data)
    transmitResponse data['seq'].to_i, true, {}
  end

  def submit_patch(data)
    puts 'Processing patch ' + data['patch'].lines.join("\\n")
    if @classroom.apply_patch(data['patch'])
      transmitResponse data['seq'].to_i, true, {}
      broadcast 'patch', author: @client_id, patch: data['patch']
    else
      transmitResponse data['seq'].to_i, false, {}
    end
  end

  private
    def transmitResponse(seq, success, payload)
      transmit success: success, seq: seq, payload: payload
    end

    def broadcast(type, payload)
      ActionCable.server.broadcast "classroom_#{@classroom_id}", {type: type, payload: payload}
    end
end
