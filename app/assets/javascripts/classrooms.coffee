# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class CodeEditor
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

    window.outputDisplay.append('There have been conflicting edits. We need to revert your edit ):') unless silent

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

class OutputDisplay
  constructor: (divId) ->
    @initial = "Here would go the output from your program ;)"

    @display = ace.edit(divId)

    @display.setTheme('ace/theme/monokai')
    @display.setOptions
      readOnly: true,
      wrap: true, 
      highlightActiveLine: false,
      highlightGutterLine: false

    @display.$blockScrolling = Infinity

    @clear()

  append: (content) ->
    @display.setValue(@display.getValue() + "\n\n" + content, 1)

  clear: ->
    @display.setValue(@initial, 1)

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


class PingDisplay
  constructor: (divId) ->
    @display = $('#' + divId)

    @pingState =
      sequence: 0
      succeeded: true

    @queryPing()

  queryPing: ->
    nextDelay = 5000

    unless @pingState.succeeded
      @display.text('Disconnected')

    @pingState.succeeded = false

    if window.cableReady
      @pingState.sequence += 1
      @pingState.initiatedAt = Date.now()

      App.classroom.queryPing(@pingState.sequence)
    else
      nextDelay = 100

    setTimeout =>
      @queryPing()
    , nextDelay


  postResult: (sequence) ->
    if sequence == @pingState.sequence
      delay = Date.now() - @pingState.initiatedAt
      @pingState.succeeded = true
      @display.text(delay + ' ms')

class Toolbar
  constructor: (divId) ->
    @toolbar = $('#' + divId)

    @running = false

    @toolbar.children('#run').click =>
      @handleRun()
    @toolbar.children('#clear').click =>
      @handleClear()

  handleRun: ->
    return if @running
    @running = true
    @toolbar.children('#run').text('Running...')
    window.outputDisplay.append('Running your code...')
    App.classroom.run()

  handleClear: ->
    window.outputDisplay.clear()

  postRunFinish: ->
    @running = false
    @toolbar.children('#run').text('Run')

ready = ->
  if $('body#classrooms_show').length > 0
    # Set up the editor and output display
    window.codeEditor = new CodeEditor 'editor'
    window.outputDisplay = new OutputDisplay 'output'
    window.attendanceDisplay = new AttendanceDisplay
    window.pingDisplay = new PingDisplay 'ping'
    window.toolbar = new Toolbar 'toolbar'

$(document).ready(ready)
$(document).on('page:load', ready)