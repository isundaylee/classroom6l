require 'merger'
require 'mergers/naive_merger'

class ChangeCodeJob < ApplicationJob
  queue_as :default

  MERGER = NaiveMerger

  def perform(classroom_id, client_id, patch_text)
    classroom = Classroom.find(classroom_id)

    dmp = DiffMatchPatch.new
    patches = dmp.patch_fromText(patch_text)
    new_code, success = dmp.patch_apply(patches, classroom.code)

    if success.all?
      classroom.code = new_code
      classroom.save!

      ActionCable.server.broadcast "classroom_#{classroom_id}", {
        type: 'submit_patch_result',
        payload: {
          success: true,
          client_id: client_id,
          patch: patch_text
        }
      }
    else
      ActionCable.server.broadcast "classroom_#{classroom_id}", {
        type: 'submit_patch_result',
        payload: {
          success: false,
          client_id: client_id
        }
      }
    end
  end
end
