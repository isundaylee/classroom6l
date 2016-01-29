require 'tempfile'
require 'json'

class RunCodeJob < ApplicationJob
  queue_as :default

  CODE_RUNNER_URL = Rails.env.production? ?
    ENV['CODE_RUNNER_URL'] :
    'localhost:9797'

  def perform(classroom_id, code)
    classroom = Classroom.find(classroom_id)
    tmpfile = Tempfile.new(['code', '.' + classroom.language_extension])
    tmpfile.write(code)
    tmpfile.close

    begin
      response = RestClient.post(CODE_RUNNER_URL, code: File.new(tmpfile.path))
      result = JSON.parse(response.to_s)
      
      ActionCable.server.broadcast "classroom_#{classroom_id}", {
        type: 'run_result',
        payload: result
      }
    rescue RestClient::Exception => e
      ActionCable.server.broadcast "classroom_#{classroom_id}", {
        type: 'run_result',
        payload: {
          success: false,
          error: 'Error connecting to code runner server. '
        }
      }
    end
  end
end
