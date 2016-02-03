@ParchmentList = React.createClass
  displayName: 'ParchmentList'

  getInitialState: ->
    parchments: {}
    activeParchmentId: null

  editParchment: (parchmentId, parchmentPath) ->
    App.PubSub.publish 'switchToParchment', parchmentId: parchmentId, parchmentPath: parchmentPath

  componentDidMount: ->
    App.classroom.onConnect =>
      @updateParchments()
      @updateParchmentsInterval = setInterval =>
        @updateParchments()
      , 1000 unless @updateParchmentsInterval

    App.PubSub.subscribe 'didSwitchToParchment', (data) =>
      @changeState activeParchmentId: data.parchmentId

    App.PubSub.subscribe 'refreshParchmentList', =>
      @updateParchments()

  updateParchments: ->
    App.classroom.listParchments().onSuccess (data) =>
      @changeState parchments: data.parchments
    .send() 

  render: ->
    <ul className="parchment-list">
      {
        _.map @state.parchments, (path, id) =>
          id = parseInt(id)
          <li onClick={ @editParchment.bind(this, id, path) }
                  key={ id } 
            className={ if @state.activeParchmentId == id then 'active' else '' }>
            { path }
          </li>
      }
    </ul>

  # Utility boilerplate

  changeState: (changes) ->
    @setState (state) ->
      _.merge state, changes