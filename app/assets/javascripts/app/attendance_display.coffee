class App.AttendanceDisplay
  constructor: () ->
    @updateAttendance()

  updateAttendance: ->
    $('#attendance').empty().append(_.map(App.dataStore.getAttendance(), (username) ->
      $('<li>').text(username)
    ))

    App.classroom.queryAttendance()

    setTimeout =>
      @updateAttendance()
    , 1000
