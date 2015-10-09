###*
# Cast value as observable, if it already is then just return otherwise wrap it in an observable
###
ko.asObservable = (value) ->
  if ko.isObservable(value) then value else ko.observable(value)

###*
# Cast value as observableArray, if it already is then just return otherwise wrap it in an observableArray
###
ko.asObservableArray = (value) ->
  if ko.isObservable(value) then value else ko.observableArray(value)
