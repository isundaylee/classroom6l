# @cjsx React.DOM

@StatusBar = React.createClass
  displayName: 'StatusBar'

  getInitialState: ->
    ping: null
    attendance: []

  componentDidMount: ->
    App.classroom.onConnect =>
      @triggerPing()
      setInterval =>
        @triggerPing()
      , 5000

      @queryAttendance()
      setInterval =>
        @queryAttendance()
      , 1000

  triggerPing: ->
    startedAt = Date.now()

    App.classroom.ping().setTimeout(4000).onSuccess =>
      @setState (state) ->
        _.merge @state, {ping: Date.now() - startedAt}
    .onTimeout =>
      @setState (state) ->
        _.merge @state, {ping: null}
    .send()

  queryAttendance: ->
    App.classroom.queryAttendance().onSuccess (data) =>
      @setState (state) ->
        _.merge @state, {attendance: data.attendance}
    .send()

  render: -> 
    <div className="status-bar">
      <ul className="attendance">
        {
          _.map @state.attendance, (person) ->
            <li key={ person }>{ person }</li>
        }
      </ul>
      <span className="ping">{ @state.ping || "???" } ms</span>
    </div>