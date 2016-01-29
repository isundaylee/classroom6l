@CodeEditor = React.createClass
  displayName: 'CodeEditor'

  getInitialState: ->
    code: ''
    readOnly: false
    ignoreChanges: false

  componentDidMount: ->
    @dmp = new diff_match_patch
    @queuedPatches = []

    App.classroom.onConnect =>
      @syncCode()

    App.classroom.onReceivingBroadcastOfType 'patch', (data) =>
      @queuedPatches.push(data.payload.patch) unless data.payload.author == gon.client_id
      @armSilenceTrigger()

  # Code syncing logic

  syncCode: ->
    @changeState readOnly: true

    App.classroom.sync().onSuccess (data) =>
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
      , 500

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
    App.classroom.submitPatch(patchText).onError(onFailure).onTimeout(onFailure).send()

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
    <AceEditor mode={ gon.language } 
              theme="monokai" 
               name="code_editor" 
              width='' 
             height='' 
           onChange={ @onCodeChange } 
              value={ @state.code } 
           readOnly={ @state.readOnly } />

  # Utility boilerplate

  changeState: (changes) ->
    @setState (state) ->
      _.merge state, changes