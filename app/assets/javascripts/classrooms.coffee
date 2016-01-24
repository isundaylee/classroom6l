# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  if $('body#classrooms_show').length > 0
    window.editor = ace.edit('editor')
    editor.setTheme('ace/theme/monokai')
    editor.getSession().setMode('ace/mode/ruby')

    # Bind the buttons
    $('#run').click ->
      alert('Gotta run some code. ')

$(document).ready(ready)
$(document).on('page:load', ready)