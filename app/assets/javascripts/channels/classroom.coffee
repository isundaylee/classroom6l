App.classroom = App.cable.subscriptions.create {channel: "ClassroomChannel", classroom_id: gon.classroom_id, client_id: gon.client_id},
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    switch data.type
      when 'run_result'
        if data.payload.success
          window.appendOutput("The result of your code is: ")
          window.appendOutput(data.payload.stdout)
          if data.payload.stderr.length > 0
            window.appendOutput("It generated the following error(s) ):")
            window.appendOutput(data.payload.stderr)
        else
          alert('Error: ' + data.payload.error)
      when 'submit_patch_result'
        if data.payload.success
          if data.payload.client_id == gon.client_id
            # Our patch went through
          else
            # TODO: apply other's patch
        else
          if data.payload.client_id == gon.client_id
            # TODO: our patch is rejected
            console.log('Oops. Our patch is rejected. ')
          else
            # Other people's patch is rejected.
      else
        console.log("Unrecognised message received: " + data)

  run: ->
    @perform 'run'

  submitPatch: (patchText) ->
    @perform 'submit_patch', patch: patchText
