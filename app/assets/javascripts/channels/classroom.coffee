App.classroom = App.cable.subscriptions.create {channel: "ClassroomChannel", classroom_id: gon.classroom_id},
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    switch data.type
      when 'run_result'
        if data.payload.success
          window.append_output("The result of your code is: ")
          window.append_output(data.payload.stdout)
        else
          alert('Error: ' + data.payload.error)
      else
        console.log("Unrecognised message received: " + data)

  run: ->
    @perform 'run', classroom_id: gon.classroom_id
