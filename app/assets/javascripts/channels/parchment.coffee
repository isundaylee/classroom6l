App.createParchmentChannel = (parchment_id) ->
  channel = App.cable.subscriptions.create {channel: "ParchmentChannel", parchment_id: parchment_id, client_id: gon.client_id}, 
    submitPatch: (patchText) ->
      new App.CableRequest(@, 'submit_patch', patch: patchText)

    sync: ->
      new App.CableRequest(@, 'sync')

  _.extend(channel, App.CableRequestManager)
  channel.setup()

  channel
