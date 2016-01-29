class App.PubSub
  @subscribers = {}

  @subscribe: (topic, cb) ->
    @subscribers[topic] ||= {}
    token = 'sub_' + _.guid()
    @subscribers[topic][token] = cb
    token

  @unsubscribe: (topic, token) ->
    delete @subscribers[topic][token]

  @publish: (topic, payload) ->
    if @subscribers[topic]
      @subscribers[topic][token](payload) for token of @subscribers[topic]
