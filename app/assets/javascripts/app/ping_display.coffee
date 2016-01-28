class App.PingDisplay
  constructor: (divId) ->
    @display = $('#' + divId)

    @pingState =
      sequence: 0
      succeeded: true

    @queryPing()

  queryPing: ->
    nextDelay = 5000

    unless @pingState.succeeded
      @display.text('Disconnected')

    @pingState.succeeded = false

    if App.cableReady
      @pingState.sequence += 1
      @pingState.initiatedAt = Date.now()

      App.classroom.queryPing(@pingState.sequence)
    else
      nextDelay = 100

    setTimeout =>
      @queryPing()
    , nextDelay


  postResult: (sequence) ->
    if sequence == @pingState.sequence
      delay = Date.now() - @pingState.initiatedAt
      @pingState.succeeded = true
      @display.text(delay + ' ms')
