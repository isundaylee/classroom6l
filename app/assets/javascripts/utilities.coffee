_.merge = (args...) ->
  _.extend {}, args...

_.guid = ->
  s4 = ->
    Math.floor((1 + Math.random()) * 0x10000).toString(16).substring 1
  s4() + s4() + s4() + s4() + s4() + s4() + s4() + s4()