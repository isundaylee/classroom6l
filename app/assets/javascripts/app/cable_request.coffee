class App.CableRequest
  STAGES =
    unsent: 0
    sent: 1
    successful: 2
    failed: 3
    timedOut: 4

  constructor: (channel, method, params = {}) ->
    @channel = channel
    @method = method
    @params = params
    @timeout = 5000
    @started = false
    @stage = STAGES.unsent

    @successCallback = ->
    @errorCallback = ->
    @timeoutCallback = ->

  setTimeout: (timeout) ->
    @timeout = timeout
    this

  onSuccess: (cb) ->
    @successCallback = cb
    this

  onError: (cb) ->
    @errorCallback = cb
    this

  onTimeout: (cb) ->
    @timeoutCallback = cb
    this

  send: ->
    @stage = STAGES.sent

    @channel.performWithCallback @method, @params, (data) =>
      return if @stage == STAGES.timedOut

      clearTimeout(@timeoutHandle)

      if data.success
        @successCallback(data.payload)
      else
        @errorCallback(data.payload)

    @timeoutHandle = setTimeout =>
      return unless @stage == STAGES.sent
      @stage = STAGES.timedOut
      @timeoutCallback()
    , @timeout
