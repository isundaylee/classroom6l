App.classroom = App.cable.subscriptions.create {channel: "ClassroomChannel", classroom_id: gon.classroom_id, client_id: gon.client_id},
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    switch data.type
      when 'run_result' then @handleRunResult(data)
      when 'submit_patch_result' then @handleSubmitPatchResult(data)
      else console.log("Unrecognised message received: " + data)

  handleRunResult: (data) ->
    if data.payload.success
      window.outputDisplay.append("The result of your code is: ")
      window.outputDisplay.append(data.payload.stdout)
      if data.payload.stderr.length > 0
        window.outputDisplay.append("It generated the following error(s) ):")
        window.outputDisplay.append(data.payload.stderr)
      window.running = false
      $('#run').html('Run')
    else
      alert('Error: ' + data.payload.error)

  handleSubmitPatchResult: (data) ->
    if data.payload.success
      if data.payload.client_id == gon.client_id
        # Yay - our patch went through.
      else
        # We delay updating editor to the recurring function.
        window.codeEditor.enquePatch(data.payload.patch)
    else
      if data.payload.client_id == gon.client_id
        # TODO: our patch is rejected
        console.log('Oops. Our patch is rejected. ')
      else
        # Some poor soul's patch is rejected.

  run: ->
    @perform 'run'

  submitPatch: (patchText) ->
    @perform 'submit_patch', patch: patchText
