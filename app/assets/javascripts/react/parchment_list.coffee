@ParchmentList = React.createClass
  displayName: 'ParchmentList'

  getInitialState: ->
    parchments: {}
    activeParchmentId: null

  editParchment: (parchment_id) ->
    App.PubSub.publish 'switch_to_parchment', parchment_id: parchment_id

  componentDidMount: ->
    App.classroom.onConnect =>
      @updateParchments()
      @updateParchmentsInterval = setInterval =>
        @updateParchments()
      , 1000 unless @updateParchmentsInterval

    App.PubSub.subscribe 'did_switch_to_parchment', (data) =>
      @changeState activeParchmentId: data.parchmentId

  updateParchments: ->
    App.classroom.listParchments().onSuccess (data) =>
      @changeState parchments: data.parchments
    .send() 

  render: ->
    <ul className="parchment-list">
      {
        _.map @state.parchments, (path, id) =>
          id = parseInt(id)
          <li onDoubleClick={ @editParchment.bind(this, id) }
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