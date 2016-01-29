App.classroom = App.cable.subscriptions.create {channel: "ClassroomChannel", classroom_id: gon.classroom_id, client_id: gon.client_id, username: App.DataStore.getSharedInstance().getUsername()},
  connected: ->
    @seq = 0
    @requestCallbacks = {}

    App.cableReady = true
    @isConnected = true

    if @connectCallbacks
      cb() for cb in @connectCallbacks

  disconnected: ->
    App.cableReady = false
    @isConnected = false

    if @disconnectCallbacks
      cb() for cb in @disconnectCallbacks

  received: (data) ->
    if data.seq
      # CableRequest responses
      if @requestCallbacks[data.seq]
        @requestCallbacks[data.seq](data) 
        delete @requestCallbacks[data.seq]
    else
      # Broadcasts
      if @broadcastCallbacks && @broadcastCallbacks[data.type]
        cb(data) for cb in @broadcastCallbacks[data.type]

  # Actions

  run: ->
    new App.CableRequest(this, 'run')

  queryAttendance: ->
    new App.CableRequest(this, 'query_attendance')

  ping: ->
    new App.CableRequest(this, 'ping')

  sync: ->
    new App.CableRequest(this, 'sync')

  submitPatch: (patch) ->
    new App.CableRequest(this, 'submit_patch', patch: patch)

  # Callback infrastructure
  
  onConnect: (cb) ->
    @connectCallbacks ||= []
    @connectCallbacks.push(cb)
    cb() if @isConnected

  onDisconnect: (cb) ->
    @disconnectCallbacks ||= []
    @disconnectCallbacks.push(cb)

  performWithCallback: (method, params, cb) ->
    @seq += 1
    @requestCallbacks[@seq] = cb
    @perform method, _.merge(params, {seq: @seq})

  onReceivingBroadcastOfType: (type, cb) ->
    @broadcastCallbacks ||= {}
    @broadcastCallbacks[type] ||= []
    @broadcastCallbacks[type].push(cb)
