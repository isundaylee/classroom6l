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
      lastSeenContent: @editor.getValue()
    @submitState =
      lastSentContent: @editor.getValue()
      needsRevert: false
    @revertState =
      inProgress: false
      finished: false
    @patchQueue = []

    @dmp = new diff_match_patch

    @pollingLoop()

  enquePatch: (patch) ->
    @patchQueue.push(patch)

  postRevertResult: (code) ->
    if @revertState.inProgress
      @revertState.finished = true
      @revertState.result = code

  postNeedsRevert: ->
    @submitState.needsRevert = true

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

  triggerRevert: ->
    return if @revertState.inProgress

    window.outputDisplay.append('There have been conflicting edits. We need to revert your edit ):')

    @revertState.inProgress = true
    @revertState.finished = false
    @editor.setOptions readOnly: true
    App.classroom.revert()

  applyPendingPatches: ->
    patchApplied = false
    content = @editor.getValue()
    patchedContent = content

    for p in @patchQueue
      patches = @dmp.patch_fromText(p)
      [patchedContent, success] = @dmp.patch_apply(patches, patchedContent)
      allSuccess = _.every(success, _.identity)

      unless allSuccess
        console.log('Oops. Failed to apply patch. Forcing syncing. ')
        @triggerRevert()

    # TODO: potentially thread unsafe
    @patchQueue = []

    # Do NOT submitChange() here as they are not our changes.
    @updateContent(patchedContent) if patchedContent != content

  submitChanges: ->
    content = @editor.getValue()
    patchesToSubmit = @dmp.patch_make(@submitState.lastSentContent, content)
    patchTextToSubmit = @dmp.patch_toText(patchesToSubmit)
    App.classroom.submitPatch(patchTextToSubmit)
    @dirtyState.dirty = false
    @submitState.lastSentContent = content

  pollingLoop: ->
    if @submitState.needsRevert
      @submitState.needsRevert = false
      @triggerRevert()

    if @revertState.finished
      @updateContent(@revertState.result)
      @editor.setOptions readOnly: false
      @revertState.inProgress = false
      @revertState.finished = false

    unless @revertState.inProgress
      @checkAndSubmitDirty()
      @applyPendingPatches()

    setTimeout =>
      @pollingLoop()
    , 50

class OutputDisplay
  constructor: (divId) ->
    @display = ace.edit(divId)

    @display.setTheme('ace/theme/monokai')
    @display.setOptions
      readOnly: true,
      highlightActiveLine: false,
      highlightGutterLine: false

    @display.$blockScrolling = Infinity

  append: (content) ->
    @display.setValue(@display.getValue() + "\n\n" + content, 1)

class AttendanceDisplay
  constructor: () ->
    @updateAttendance()

  updateAttendance: ->
    $('#attendance').empty().append(_.map(window.dataStore.getAttendance(), (username) ->
      $('<li>').text(username)
    ))

    App.classroom.queryAttendance()

    setTimeout =>
      @updateAttendance()
    , 1000


ready = ->
  if $('body#classrooms_show').length > 0
    # Set up the editor and output display
    window.codeEditor = new CodeEditor 'editor'
    window.outputDisplay = new OutputDisplay 'output'
    window.attendanceDisplay = new AttendanceDisplay

    # Bind the buttons
    $('#run').click ->
      return if window.running
      window.running = true
      $(this).html('Running...')
      window.outputDisplay.append('Running your code...')
      App.classroom.run()

$(document).ready(ready)
$(document).on('page:load', ready)