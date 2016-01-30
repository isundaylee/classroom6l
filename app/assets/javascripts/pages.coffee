# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  if $('body#pages_homepage').length > 0
    $('#python').click ->
      $('#template').val('python')
      $('form').submit()
    $('#ruby').click ->
      $('#template').val('ruby')
      $('form').submit()

$(document).ready(ready)
$(document).on('page:load', ready)