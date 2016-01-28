class App.DataStore
  constructor: ->
    return this

  getUsername: ->
    if !localStorage.username
      localStorage.username = window.prompt('What would you want to call yourself? ', 'Random Coder')
    return localStorage.username

  setAttendance: (attendance) ->
    @attendance = attendance

  getAttendance: ->
    @attendance