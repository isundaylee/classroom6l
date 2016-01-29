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
    switch data.type
      when 'run_result' then (@handleRunResult(data); return)

    if data.seq
      # CableRequest responses
      if @requestCallbacks[data.seq]
        @requestCallbacks[data.seq](data) 
        delete @requestCallbacks[data.seq]
      return
    else
      # Broadcasts
      if @broadcastCallbacks && @broadcastCallbacks[data.type]
        cb(data) for cb in @broadcastCallbacks[data.type]
      return

  # Message handlers

  handleRunResult: (data) ->
    if data.payload.success
      App.outputDisplay.append("The result of your code is: ")
      App.outputDisplay.append(data.payload.stdout)
      if data.payload.stderr.length > 0
        App.outputDisplay.append("It generated the following error(s) ):")
        App.outputDisplay.append(data.payload.stderr)
      App.toolbar.postRunFinish()
    else
      alert('Error: ' + data.payload.error)

  # Actions

  run: ->
    @perform 'run'

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
