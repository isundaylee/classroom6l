# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  if $('body#classrooms_show').length > 0
    window.editor = ace.edit('editor')
    window.output = ace.edit('output')
    window.editor.setTheme('ace/theme/monokai')
    window.editor.getSession().setMode('ace/mode/ruby')
    window.output.setTheme('ace/theme/monokai')
    window.output.setOptions
      readOnly: true,
      highlightActiveLine: false,
      highlightGutterLine: false

    window.append_output = (content) ->
      window.output.setValue(window.output.getValue() + "\n\n" + content, 1)

    # Bind the buttons
    $('#run').click ->
      window.append_output('Running your code...')
      App.classroom.run()

$(document).ready(ready)
$(document).on('page:load', ready)