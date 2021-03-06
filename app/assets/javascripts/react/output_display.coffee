# @cjsx React.DOM

@OutputDisplay = React.createClass
  displayName: 'OutputDisplay'

  propTypes:
    defaultContent: React.PropTypes.string

  getDefaultProps: ->
    defaultContent: 'Welcome to Classroom 6.L ;) '

  getInitialState: ->
    content: ''

  componentWillMount: ->
    @clearSubToken = App.PubSub.subscribe 'clearOutputDisplay', =>
      @changeState content: @props.defaultContent

    App.PubSub.subscribe 'appendOutput', (data) =>
      @appendContent data.content

  componentWillUnmount: ->
    App.PubSub.unsubscribe 'clearOutputDisplay', @clearSubToken

  componentDidMount: ->
    App.classroom.onConnect =>
      @changeState content: @props.defaultContent

    App.classroom.onReceivingBroadcastOfType 'run_result', (data) =>
      if data.payload.success
        output = "The output of your code is: \n\n" + data.payload.stdout
        output += "\nYour code generated the following error messages: \n\n" + data.payload.stderr if data.payload.stderr != ''
        @appendContent output
      else
        @appendContent "Error running your code: " + data.payload.error

  appendContent: (content) ->
    @setState (state) ->
      _.merge state, 
        content: if state.content == '' then content else state.content + "\n\n" + content

  render: ->
    <AceEditor theme="monokai" 
                mode="plain_text"
                name="output_display" 
               width='' 
              height='' 
               value={ @state.content } 
            readOnly=true
       alwaysShowEnd=true
         wrapEnabled=true />

  # Utility boilerplate

  changeState: (changes) ->
    @setState (state) ->
      _.merge state, changes
