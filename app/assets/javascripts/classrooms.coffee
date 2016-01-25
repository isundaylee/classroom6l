# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class CodeEditor
  constructor: (divId) ->
    @editor = ace.edit(divId)
    @editor.setTheme('ace/theme/monokai')
    @editor.getSession().setMode('ace/mode/' + gon.language)
    @editor.$blockScrolling = Infinity

    @dirtyState =
      dirty: false
      silenceCounter: 0
      lastSeenContent: @editor.getValue()
    @submitState =
      lastSentContent: @editor.getValue()
    @patchQueue = []

    @dmp = new diff_match_patch

    @pollingLoop()

  enquePatch: (patch) ->
    @patchQueue.push(patch)

  # Internal methods details from now on
  checkDirty: ->
    content = @editor.getValue()
    if content == @dirtyState.lastSeenContent
      @dirtyState.silenceCounter += 1
    else
      @dirtyState.silenceCounter = 0
      @dirtyState.dirty = true
    @dirtyState.lastSeenContent = content

  updateContent: (newContent) ->
    console.assert(!@dirtyState.dirty, "updateContent() should only be called with a clean buffer. ")
    range = @editor.selection.getRange()
    @editor.setValue(newContent)
    @editor.selection.setSelectionRange(range, false)
    @dirtyState.lastSeenContent = newContent
    @submitState.lastSentContent = newContent

  applyPendingPatches: ->
    patchApplied = false
    content = @editor.getValue()
    patchedContent = content

    for p in @patchQueue
      patches = @dmp.patch_fromText(p)
      [patchedContent, success] = @dmp.patch_apply(patches, patchedContent)
      allSuccess = _.every(success, _.identity)

      unless allSuccess
        # TODO: Force syncing.
        console.log('Oops. Patch apply failed. ')

    # TODO: potentially thread unsafe
    @patchQueue = []

    if patchedContent != content
      @submitChanges()
      @updateContent(patchedContent)

  submitChanges: ->
    content = @editor.getValue()
    patchesToSubmit = @dmp.patch_make(@submitState.lastSentContent, content)
    patchTextToSubmit = @dmp.patch_toText(patchesToSubmit)
    App.classroom.submitPatch(patchTextToSubmit)
    @dirtyState.dirty = false
    @submitState.lastSentContent = content

  pollingLoop: ->
    @checkDirty()
    @applyPendingPatches()
    @submitChanges() if @dirtyState.silenceCounter >= 3 && @dirtyState.dirty

    setTimeout =>
      @pollingLoop()
    , 100

class OutputDisplay
  constructor: (divId) ->
    @display = ace.edit(divId)

    @display.setTheme('ace/theme/monokai')
    @display.setOptions
      readOnly: true,
      highlightActiveLine: false,
      highlightGutterLine: false

  append: (content) ->
    @display.setValue(@display.getValue() + "\n\n" + content, 1)

ready = ->
  if $('body#classrooms_show').length > 0
    # Set up the editor and output display
    window.codeEditor = new CodeEditor 'editor'
    window.outputDisplay = new OutputDisplay 'output'

    # Bind the buttons
    $('#run').click ->
      window.outputDisplay.append('Running your code...')
      App.classroom.run()

$(document).ready(ready)
$(document).on('page:load', ready)