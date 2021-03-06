App.classroom = App.cable.subscriptions.create {channel: "ClassroomChannel", classroom_id: gon.classroom_id, client_id: gon.client_id, username: App.DataStore.getSharedInstance().getUsername()},
  run: ->
    new App.CableRequest(this, 'run')

  queryAttendance: ->
    new App.CableRequest(this, 'query_attendance')

  ping: ->
    new App.CableRequest(this, 'ping')

  listParchments: ->
    new App.CableRequest(this, 'list_parchments')

  newParchment: (path) ->
    new App.CableRequest(this, 'new_parchment', path: path)
    
_.extend(App.classroom, App.CableRequestManager)
App.classroom.setup()