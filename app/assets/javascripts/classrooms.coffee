# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'page:change', ->
  if $('body#classrooms_show').length > 0
    # Set up the editor and output display
    App.outputDisplay = new App.OutputDisplay 'output'
    App.toolbar = new App.Toolbar 'toolbar'