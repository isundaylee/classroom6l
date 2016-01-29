@CodeEditor = React.createClass
  displayName: 'CodeEditor'

  propTypes:
    parchmentId: React.PropTypes.number

  getInitialState: ->
    code: ''
    readOnly: false
    ignoreChanges: false

  componentDidMount: ->
    @dmp = new diff_match_patch

    @initialiseParchment(@props.parchmentId)

  initialiseParchment: (parchmentId) ->
    @setState @getInitialState()

    @channel.unsubscribe() if (@channel && @channel.isConnected)
    @queuedPatches = []
    @channel = App.createParchmentChannel(parchmentId)

    @channel.onConnect =>
      App.PubSub.publish 'did_switch_to_parchment', parchmentId: parchmentId
      @syncCode()

    @channel.onReceivingBroadcastOfType 'patch', (data) =>
      @queuedPatches.push(data.payload.patch) unless data.payload.author == gon.client_id
      @armSilenceTrigger()

  componentWillReceiveProps: (nextProps) ->
    if nextProps.parchmentId != @props.parchmentId
      @initialiseParchment(nextProps.parchmentId)

  # Code syncing logic

  syncCode: ->
    @changeState readOnly: true

    @channel.sync().onSuccess (data) =>
      @changeState ignoreChanges: true
      @submittedCode = data.content
      @changeState code: data.content
      @changeState ignoreChanges: false, readOnly: false
    .send()

  onCodeChange: (newCode) ->
    return if @state.ignoreChanges

    clearTimeout(@silenceTriggerTimeout) if @silenceTriggerTimeout
    @silenceTriggerTimeout = null

    @changeState code: newCode
    @armSilenceTrigger()

  armSilenceTrigger: ->
    unless @silenceTriggerTimeout
      @silenceTriggerTimeout = setTimeout =>
        @silenceTrigger()
      , 250

  silenceTrigger: ->
    @silenceTriggerTimeout = null
    @submitChanges()
    @applyQueuedPatches()

  submitChanges: ->
    return if @submittedCode == @state.code

    patch = @dmp.patch_make(@submittedCode, @state.code)
    patchText = @dmp.patch_toText(patch)

    onFailure = =>
      @syncCode()

    @submittedCode = @state.code
    @channel.submitPatch(patchText).onError(onFailure).onTimeout(onFailure).send()

  applyQueuedPatches: ->
    for patch in @queuedPatches
      patches = @dmp.patch_fromText(patch)
      [newCode, success] = @dmp.patch_apply(patches, @state.code)

      if _.every(success, _.identity)
        @changeState ignoreChanges: true
        @submittedCode = newCode
        @changeState code: newCode
        @changeState ignoreChanges: false
      else
        @queuedPatches = []
        @syncCode()
    @queuedPatches = []

  # React rendering logic

  render: ->
    <AceEditor mode={ gon.lang } 
              theme="monokai" 
               name="code_editor" 
              width='' 
             height='' 
           onChange={ @onCodeChange } 
              value={ @state.code } 
           readOnly={ @state.readOnly }
        wrapEnabled=true />

  # Utility boilerplate

  changeState: (changes) ->
    @setState (state) ->
      _.merge state, changes