require 'merger'
require 'mergers/naive_merger'

class ChangeCodeJob < ApplicationJob
  queue_as :default

  MERGER = NaiveMerger

  def perform(classroom_id, previous, updated)
    classroom = Classroom.find(classroom_id)
    merger = MERGER.new

    begin
      classroom.code = merger.merge(previous, classroom.code, updated)
      classroom.save!

      ActionCable.server.broadcast "classroom_#{classroom_id}", {
        type: 'submit_change_result',
        payload: {
          result: classroom.code
        }
      }
    rescue Merger::CannotMergeException => e
      ActionCable.server.broadcast "classroom_#{classroom_id}", {
        type: 'submit_change_result',
        payload: {
          result: classroom.code
        }
      }
    end
  end
end
