@Classroom = React.createClass
  displayName: 'Classroom' 

  getInitialState: ->
    activeParchmentId: gon.main_parchment_id

  componentDidMount: ->
    App.PubSub.subscribe 'switch_to_parchment', (data) =>
      @changeState activeParchmentId: data.parchment_id

  render: ->
    <div className='classroom'>
      <h1>Welcome to { gon.classroom_name }</h1>
      <Toolbar />
      <ParchmentList />
      <CodeEditor parchmentId={ @state.activeParchmentId } />
      <OutputDisplay />
      <StatusBar />
    </div>

  # Utility boilerplate

  changeState: (changes) ->
    @setState (state) ->
      _.merge state, changes