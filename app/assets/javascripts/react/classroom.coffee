@Classroom = React.createClass
  displayName: 'Classroom' 

  render: ->
    <div className='classroom'>
      <h1>Welcome to { gon.classroom_name }</h1>
      <Toolbar />
      <CodeEditor parchmentId={ gon.main_parchment_id } />
      <OutputDisplay />
      <StatusBar />
    </div>
