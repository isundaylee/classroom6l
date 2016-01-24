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
          if data.payload.stderr.length > 0
            window.appendOutput("It generated the following error(s) ):")
            window.appendOutput(data.payload.stderr)
        else
          alert('Error: ' + data.payload.error)
      when 'submit_change_result'
        if data.payload.result != window.editor.getValue()
          pos = window.editor.session.selection.toJSON()
          window.editor.setValue(data.payload.result, 1)
          window.editor.session.selection.fromJSON(pos)
        else
          console.log('Broadcast matches ours! ')
      else
        console.log("Unrecognised message received: " + data)

  run: ->
    @perform 'run', classroom_id: gon.classroom_id

  submitChange: (previous, updated) ->
    @perform 'submit_change', classroom_id: gon.classroom_id, previous: previous, updated: updated
