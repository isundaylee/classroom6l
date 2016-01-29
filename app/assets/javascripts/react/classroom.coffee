@Classroom = React.createClass
  displayName: 'Classroom' 

  getInitialState: ->
    activeParchmentId: gon.main_parchment_id,
    activeParchmentPath: gon.main_parchment_path

  componentDidMount: ->
    App.PubSub.subscribe 'switchToParchment', (data) =>
      @changeState activeParchmentId: data.parchmentId, activeParchmentPath: data.parchmentPath

  render: ->
    <div className='classroom'>
      <h1>Welcome to { gon.classroom_name }</h1>
      <Toolbar />
      <ParchmentList />
      <CodeEditor parchmentId={ @state.activeParchmentId } parchmentPath={ @state.activeParchmentPath } />
      <OutputDisplay />
      <StatusBar />
    </div>

  # Utility boilerplate

  changeState: (changes) ->
    @setState (state) ->
      _.merge state, changes