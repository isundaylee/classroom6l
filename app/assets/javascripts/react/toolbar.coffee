# @cjsx React.DOM

@Toolbar = React.createClass
  displayName: 'Toolbar'

  getInitialState: ->
    running: false

  componentDidMount: ->
    App.classroom.onConnect =>
      @appendContent 'Welcome! '

    App.classroom.onReceivingBroadcastOfType 'run_result', =>
      @changeState running: false

  appendContent: (content) ->
    @setState (state) ->
      _.merge state, 
        content: if state.content == '' then content else state.content + "\n\n" + content

  # Handle actions

  onRun: ->
    @changeState running: true
    App.classroom.run().send()

  # React rendering

  render: ->
    <div className='toolbar'>
      <div className='run' onClick={ @onRun }>{ if @state.running then 'Running...' else 'Run' }</div>
      <div className='clear'>Clear</div>
    </div>

  # Utility boilerplate

  changeState: (changes) ->
    @setState (state) ->
      _.merge state, changes
