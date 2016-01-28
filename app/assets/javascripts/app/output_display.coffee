class App.OutputDisplay
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
    lineNumber = @display.session.getLength() - 1
    @display.scrollToLine(lineNumber, true, true, ->)
    @display.gotoLine(lineNumber, 0, true)

  clear: ->
    @display.setValue(@initial, 1)
