# @cjsx React.DOM

@OutputDisplay = React.createClass
  displayName: 'OutputDisplay'

  getInitialState: ->
    content: ''

  componentDidMount: ->
    App.classroom.onConnect =>
      @appendContent 'Welcome to Classroom 6.L ;) '

    App.classroom.onReceivingBroadcastOfType 'run_result', (data) =>
      output = "The output of your code is: \n\n" + data.payload.stdout
      output += "\n Your code generated the following error messages: \n\n" + data.payload.stderr if data.payload.stderr != ''
      @appendContent output

  appendContent: (content) ->
    @setState (state) ->
      _.merge state, 
        content: if state.content == '' then content else state.content + "\n\n" + content

  render: ->
    <AceEditor theme="monokai" 
                name="output_display" 
               width='' 
              height='' 
               value={ @state.content } 
            readOnly=true />

  # Utility boilerplate

  changeState: (changes) ->
    @setState (state) ->
      _.merge state, changes
