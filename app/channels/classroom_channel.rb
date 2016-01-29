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
    @classroom.reload
    RunCodeJob.perform_later(@classroom_id, @classroom.code)
    transmitResponse data['seq'].to_i, true, {}
  end

  def query_attendance(data)
    transmitResponse data['seq'].to_i, true, attendance: @classroom.attendance_get
  end

  def ping(data)
    transmitResponse data['seq'].to_i, true, {}
  end

  private
    def broadcast_channel
      "classroom_#{@classroom_id}"
    end
end
