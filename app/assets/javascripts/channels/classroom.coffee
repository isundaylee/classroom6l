App.classroom = App.cable.subscriptions.create {channel: "ClassroomChannel", classroom_id: gon.classroom_id, client_id: gon.client_id, username: App.DataStore.getSharedInstance().getUsername()},
  connected: ->
    App.cableReady = true

    # Load the initial code
    App.codeEditor.postNeedsRevert(true)

  disconnected: ->
    App.cableReady = false

  received: (data) ->
    switch data.type
      when 'run_result' then @handleRunResult(data)
      when 'submit_patch_result' then @handleSubmitPatchResult(data)
      when 'revert_result' then @handleRevertResult(data)
      when 'query_attendance_result' then @handleQueryAttendanceResult(data)
      when 'query_ping_result' then @handleQueryPingResult(data)
      else console.log("Unrecognised message received: " + data)

  # Message handlers

  handleRunResult: (data) ->
    if data.payload.success
      App.outputDisplay.append("The result of your code is: ")
      App.outputDisplay.append(data.payload.stdout)
      if data.payload.stderr.length > 0
        App.outputDisplay.append("It generated the following error(s) ):")
        App.outputDisplay.append(data.payload.stderr)
      App.toolbar.postRunFinish()
    else
      alert('Error: ' + data.payload.error)

  handleSubmitPatchResult: (data) ->
    if data.payload.success
      if data.payload.client_id == gon.client_id
        # Yay - our patch went through.
      else
        # We delay updating editor to the recurring function.
        App.codeEditor.enquePatch(data.payload.patch)
    else
      if data.payload.client_id == gon.client_id
        console.log('Oops. Our patch is rejected. ')
        App.codeEditor.postNeedsRevert()
      else
        # Some poor soul's patch is rejected.

  handleRevertResult: (data) ->
    App.codeEditor.postRevertResult(data.payload.code)

  handleQueryAttendanceResult: (data) ->
    App.DataStore.getSharedInstance().setAttendance(data.payload.attendance)

  handleQueryPingResult: (data) ->
    if data.payload.client_id == gon.client_id
      App.pingDisplay.postResult(data.payload.sequence)

  # Actions

  run: ->
    @perform 'run'

  submitPatches: (patchTexts) ->
    @perform 'submit_patches', patches: patchTexts

  revert: ->
    @perform 'revert'

  queryAttendance: ->
    @perform 'query_attendance'

  queryPing: (sequence) ->
    @perform 'query_ping', sequence: sequence

