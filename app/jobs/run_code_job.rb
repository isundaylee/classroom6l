require 'tempfile'
require 'json'

class RunCodeJob < ApplicationJob
  queue_as :default

  CODE_RUNNER_URL = Rails.env.production? ?
    ENV['CODE_RUNNER_URL'] :
    'localhost:9797'

  def perform(classroom_id)
    classroom = Classroom.find(classroom_id)

    tmpfile = Tempfile.new(['code', '.zip'])
    tmpfile.close

    ::Zip::File.open(tmpfile.path, ::Zip::File::CREATE) do |zip|
      classroom.parchments.each do |p|
        zip.get_output_stream(p.path) { |os| os.write(p.content) }
      end
    end

    FileUtils.cp(tmpfile.path, '/tmp/output.zip')

    begin
      response = RestClient.post(CODE_RUNNER_URL, zip_file: File.new(tmpfile.path))
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
