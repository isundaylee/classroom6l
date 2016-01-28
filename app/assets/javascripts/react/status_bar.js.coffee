# @cjsx React.DOM

@StatusBar = React.createClass
  displayName: 'StatusBar'

  getInitialState: ->
    ping: -1
    lang: 'ruby'
    language: 'Ruby'
    attendance: ['Jiahao', 'Blacky']

  componentDidMount: ->
    App.classroom.registerCallback (data) =>
      return unless data.type == 'query_ping_result'
      delay = Date.now() - @pingInitiatedAt
      @pingSucceeded = true
      @setState (state) ->
        _.extend {}, state, 
          ping: delay

    @pingInitiatedAt = 0
    @pingSequence = 0
    @pingSucceeded = true
    @triggerPing()

  triggerPing: ->
    nextDelay = 5000

    unless @pingSucceeded
      @setState (state) ->
        _.extend {}, state, 
          ping: -1

    @pingSucceeded = false

    if App.cableReady
      @pingSequence += 1
      @pingInitiatedAt = Date.now()

      App.classroom.queryPing(@pingSequence)
    else
      nextDelay = 100

    setTimeout =>
      @triggerPing()
    , nextDelay

  render: -> 
    <div className="status-bar">
      <ul className="attendance">
        {
          _.map @state.attendance, (person) ->
            <li key={ person }>{ person }</li>
        }
      </ul>
      <span className={"language " + @state.lang}>{ @state.language }</span>
      <span className="ping">{ @state.ping } ms</span>
    </div>