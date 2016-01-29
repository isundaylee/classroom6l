@ParchmentList = React.createClass
  displayName: 'ParchmentList'

  getInitialState: ->
    parchments: {}

  editParchment: (parchment_id) ->
    App.PubSub.publish 'edit_parchment', parchment_id: parchment_id

  componentDidMount: ->
    App.classroom.onConnect =>
      @updateParchments()
      @updateParchmentsInterval = setInterval =>
        @updateParchments()
      , 1000 unless @updateParchmentsInterval

  updateParchments: ->
    App.classroom.listParchments().onSuccess (data) =>
      @changeState parchments: data.parchments
    .send() 

  render: ->
    <ul className="parchment-list">
      {
        _.map @state.parchments, (path, id) =>
          <li key={ id } onDoubleClick={ @editParchment.bind(this, parseInt(id)) }>{ path }</li>
      }
    </ul>

  # Utility boilerplate

  changeState: (changes) ->
    @setState (state) ->
      _.merge state, changes