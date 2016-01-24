App.classroom = App.cable.subscriptions.create {channel: "ClassroomChannel", classroom_id: gon.classroom_id},
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
        else
          alert('Error: ' + data.payload.error)
      when 'submit_change_result'
        unless data.payload.success
          alert('There has been an merging conflict. Your changes to the code would unfortunately have to be reverted ):')
          window.editor.setValue(data.payload.revert, 1)
        else
          console.log('Submission success! ')
      else
        console.log("Unrecognised message received: " + data)

  run: ->
    @perform 'run', classroom_id: gon.classroom_id

  submitChange: (previous, updated) ->
    @perform 'submit_change', classroom_id: gon.classroom_id, previous: previous, updated: updated
