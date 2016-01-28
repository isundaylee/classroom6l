class App.Toolbar
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
    App.outputDisplay.append('Running your code...')
    App.classroom.run()

  handleClear: ->
    App.outputDisplay.clear()

  postRunFinish: ->
    @running = false
    @toolbar.children('#run').text('Run')
