# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  if $('body#classrooms_show').length > 0
    # Set up the editor and output display
    window.editor = ace.edit('editor')
    window.output = ace.edit('output')
    window.editor.setTheme('ace/theme/monokai')
    window.editor.getSession().setMode('ace/mode/' + gon.language)
    window.output.setTheme('ace/theme/monokai')
    window.output.setOptions
      readOnly: true,
      highlightActiveLine: false,
      highlightGutterLine: false

    # Initialise the code update state
    window.dirtyState =
      dirty: false
      silenceCounter: 0
      lastSeenContent: window.editor.getValue()
    window.submitState =
      lastSentContent: window.editor.getValue()
    window.patchQueue = []

    # Initialise diff-match-patch
    window.dmp = new diff_match_patch

    setInterval ->
      # Update the dirty state
      content = window.editor.getValue()
      if content == window.dirtyState.lastSeenContent
        window.dirtyState.silenceCounter += 1
      else
        window.dirtyState.silenceCounter = 0
        window.dirtyState.dirty = true
      window.dirtyState.lastSeenContent = content

      # Apply pending patches
      patchApplied = false
      patchedContent = content
      for p in window.patchQueue
        patches = window.dmp.patch_fromText(p)
        [patchedContent, success] = window.dmp.patch_apply(patches, patchedContent)
        allSuccess = true
        allSuccess &&= i for i in success

        unless allSuccess
          # TODO: Force syncing.
          console.log('Oops. Patch apply failed. ')

      # TODO: potentially thread unsafe
      window.patchQueue = []
      patchApplied = (patchedContent != content)

      # If it has been quiet (300ms)
      if (patchApplied || window.dirtyState.silenceCounter >= 3) && window.dirtyState.dirty
        patchesToSubmit = window.dmp.patch_make(window.submitState.lastSentContent, content)
        patchTextToSubmit = window.dmp.patch_toText(patchesToSubmit)
        App.classroom.submitPatch(patchTextToSubmit)
        window.dirtyState.dirty = false
        window.submitState.lastSentContent = content

      # Finally update the editor with patches content
      if patchApplied
        range = window.editor.selection.getRange()
        window.editor.setValue(patchedContent)
        window.editor.selection.setSelectionRange(range, false)
        window.dirtyState.lastSeenContent = patchedContent
        window.submitState.lastSentContent = patchedContent
    , 100

    window.appendOutput = (content) ->
      window.output.setValue(window.output.getValue() + "\n\n" + content, 1)

    # Bind the buttons
    $('#run').click ->
      window.appendOutput('Running your code...')
      App.classroom.run()

$(document).ready(ready)
$(document).on('page:load', ready)