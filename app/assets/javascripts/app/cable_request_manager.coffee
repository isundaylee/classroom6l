App.CableRequestManager = 
  setup: ->
    @connectCallbacks = []
    @disconnectCallbacks = []
    @requestCallbacks = {}
    @broadcastCallbacks = {}

  connected: ->
    @seq = 0
    @isConnected = true
    cb() for cb in @connectCallbacks

  disconnected: ->
    @isConnected = false
    cb() for cb in @disconnectCallbacks

  received: (data) ->
    if data.seq
      # CableRequest responses
      if @requestCallbacks[data.seq]
        @requestCallbacks[data.seq](data) 
        delete @requestCallbacks[data.seq]
    else
      # Broadcasts
      if @broadcastCallbacks[data.type]
        cb(data) for cb in @broadcastCallbacks[data.type]

  # Callback infrastructure
  
  onConnect: (cb) ->
    @connectCallbacks.push(cb)
    cb() if @isConnected

  onDisconnect: (cb) ->
    @disconnectCallbacks.push(cb)

  performWithCallback: (method, params, cb) ->
    @seq += 1
    @requestCallbacks[@seq] = cb
    @perform method, _.merge(params, {seq: @seq})

  onReceivingBroadcastOfType: (type, cb) ->
    @broadcastCallbacks[type] ||= []
    @broadcastCallbacks[type].push(cb)
