class App.CodeEditor
  constructor: (divId) ->
    @editor = ace.edit(divId)
    @editor.setTheme('ace/theme/monokai')
    @editor.getSession().setMode('ace/mode/' + gon.language)
    @editor.setOptions
      wrap: true
    @editor.$blockScrolling = Infinity

    @dirtyState =
      dirty: false
      lastSeenContent: @editor.getValue()
    @submitState =
      lastSentContent: @editor.getValue()
      countup: 0
      needsRevert: false
      needsRevertSilent: false
    @revertState =
      inProgress: false
      finished: false
    @debugState =
      patches: []
    @patchQueue = []
    @outgoingPatchQueue = []

    @dmp = new diff_match_patch

    @pollingLoop()

  enquePatch: (patch) ->
    @patchQueue.push(patch)

  postRevertResult: (code) ->
    if @revertState.inProgress
      @revertState.finished = true
      @revertState.result = code

  postNeedsRevert: (silent = false) ->
    @submitState.needsRevert = true
    @submitState.needsRevertSilent = silent

  # Debug feature
  getPatchHistory: ->
    @debugState.patches

  # Internal methods details from now on
  checkAndSubmitDirty: ->
    content = @editor.getValue()
    @dirtyState.dirty = true if content != @dirtyState.lastSeenContent
    @dirtyState.lastSeenContent = content
    @submitChanges() if @dirtyState.dirty

  updateContent: (newContent) ->
    console.assert(!@dirtyState.dirty, "updateContent() should only be called with a clean buffer. ")
    range = @editor.selection.getRange()
    @editor.setValue(newContent)
    @editor.selection.setSelectionRange(range, false)
    @dirtyState.lastSeenContent = newContent
    @submitState.lastSentContent = newContent

  triggerRevert: (silent = false)->
    return if @revertState.inProgress

    App.outputDisplay.append('There have been conflicting edits. We need to revert your edit ):') unless silent

    @revertState.inProgress = true
    @revertState.finished = false
    @editor.setOptions readOnly: true
    App.classroom.revert()

  applyPendingPatches: ->
    patchApplied = false
    content = @editor.getValue()
    patchedContent = content

    for p in @patchQueue
      @debugState.patches.push
        type: 'incoming'
        text: p

      patches = @dmp.patch_fromText(p)
      [patchedContent, success] = @dmp.patch_apply(patches, patchedContent)
      allSuccess = _.every(success, _.identity)

      unless allSuccess
        console.log('Oops. Failed to apply patch. Forcing syncing. ')
        @triggerRevert()

    # TODO: potentially thread unsafe
    @patchQueue = []

    # Do NOT submitChange() here as they are not our changes.
    if patchedContent != content
      @updateContent(patchedContent) 
      @flushOutgoingPatchQueue()

  submitChanges: ->
    content = @editor.getValue()
    patchesToSubmit = @dmp.patch_make(@submitState.lastSentContent, content)
    patchTextToSubmit = @dmp.patch_toText(patchesToSubmit)

    @debugState.patches.push
      type: 'outgoing'
      text: patchTextToSubmit

    @outgoingPatchQueue.push(patchTextToSubmit)

    @dirtyState.dirty = false
    @submitState.lastSentContent = content

  flushOutgoingPatchQueue: ->
    if @outgoingPatchQueue.length > 0
      App.classroom.submitPatches(@outgoingPatchQueue)
      @outgoingPatchQueue = []

  pollingLoop: ->
    if @submitState.needsRevert
      @submitState.needsRevert = false
      @triggerRevert(@submitState.needsRevertSilent)

    if @revertState.finished
      @updateContent(@revertState.result)
      @editor.setOptions readOnly: false
      @revertState.inProgress = false
      @revertState.finished = false

    unless @revertState.inProgress
      @checkAndSubmitDirty()
      @applyPendingPatches()

    # Now we only submit every 10 polling turns. 
    @submitState.countup += 1
    if @submitState.countup == 10
      @submitState.countup = 0
      @flushOutgoingPatchQueue() 

    setTimeout =>
      @pollingLoop()
    , 50
