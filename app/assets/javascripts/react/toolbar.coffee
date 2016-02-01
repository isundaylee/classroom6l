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
    App.PubSub.publish 'appendOutput', content: 'Running your code... '

  onClear: ->
    App.PubSub.publish 'clearOutputDisplay', {}

  onNewParchment: ->
    path = prompt('What would you want for the path of the new parchment? ', '')
    unless path == ''
      App.classroom.newParchment(path).onSuccess =>
        App.PubSub.publish 'refreshParchmentList'
      .onError (data) =>
        App.PubSub.publish 'appendOutput', content: "Cannot create the new parchment due to the following reason(s): \n\n" + data.error + "\n"
      .send()

  # React rendering

  render: ->
    <div className='toolbar'>
      <div className='run' onClick={ @onRun }>{ if @state.running then 'Running...' else 'Run' }</div>
      <div className='clear' onClick={ @onClear }>Clear</div>
      <span className='divider'></span>
      <div className='new-parchment' onClick={ @onNewParchment }>New Parchment</div>
    </div>

  # Utility boilerplate

  changeState: (changes) ->
    @setState (state) ->
      _.merge state, changes
