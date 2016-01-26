class DataStore
  constructor: ->

  getUsername: ->
    if !localStorage.username
      localStorage.username = window.prompt('What would you want to call yourself? ', 'Random Coder')
    return localStorage.username

  setAttendance: (attendance) ->
    @attendance = attendance

  getAttendance: ->
    @attendance

window.dataStore = new DataStore

App.classroom = App.cable.subscriptions.create {channel: "ClassroomChannel", classroom_id: gon.classroom_id, client_id: gon.client_id, username: window.dataStore.getUsername()},
  connected: ->
    # Load the initial code
    window.codeEditor.postNeedsRevert()

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    switch data.type
      when 'run_result' then @handleRunResult(data)
      when 'submit_patch_result' then @handleSubmitPatchResult(data)
      when 'revert_result' then @handleRevertResult(data)
      when 'query_attendance_result' then @handleQueryAttendanceResult(data)
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
        console.log('Oops. Our patch is rejected. ')
        window.codeEditor.postNeedsRevert()
      else
        # Some poor soul's patch is rejected.

  handleRevertResult: (data) ->
    window.codeEditor.postRevertResult(data.payload.code)

  handleQueryAttendanceResult: (data) ->
    window.dataStore.setAttendance(data.payload.attendance)

  run: ->
    @perform 'run'

  submitPatch: (patchText) ->
    @perform 'submit_patch', patch: patchText

  revert: ->
    @perform 'revert'

  queryAttendance: ->
    @perform 'query_attendance'

