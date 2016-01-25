# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  if $('body#classrooms_show').length > 0
    window.editor = ace.edit('editor')
    window.output = ace.edit('output')
    window.editor.setTheme('ace/theme/monokai')
    window.editor.getSession().setMode('ace/mode/' + gon.language)
    window.output.setTheme('ace/theme/monokai')
    window.output.setOptions
      readOnly: true,
      highlightActiveLine: false,
      highlightGutterLine: false
    window.lastTimeContent = window.editor.getValue()
    window.lastSentContent = window.editor.getValue()
    window.silenceCounter = 0
    window.dirty = false

    setInterval ->
      content = window.editor.getValue()
      if content == window.lastTimeContent
        window.silenceCounter += 1
      else
        window.silenceCounter = 0
        window.dirty = true
      # 1s wait period before update
      if window.dirty && window.silenceCounter >= 3
        window.dirty = false
        App.classroom.submitChange(window.lastSentContent, window.lastTimeContent)
        window.lastSentContent = window.lastTimeContent
      window.lastTimeContent = content
    , 100

    window.appendOutput = (content) ->
      window.output.setValue(window.output.getValue() + "\n\n" + content, 1)

    # Bind the buttons
    $('#run').click ->
      window.appendOutput('Running your code...')
      App.classroom.run()

$(document).ready(ready)
$(document).on('page:load', ready)