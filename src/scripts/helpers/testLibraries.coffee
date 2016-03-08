#test for required libraries
if !$?
  libraries.jquery = false
  console.error 'jQuery is required, please make sure it is included before the cyclops script.'

if !ko?
  libraries.knokcout = false
  console.error 'knockout is required, please make sure it is included before the cyclops script.'

#test for optional libraries
if !$? or !$.ui?
  libraries.jqueryUi = false
  console.log 'jQuery UI is not referenced or is referenced after cyclops some parts of cyclops may not be avalible.'
else
  libraries.jqueryUi = true

if !ko.validation?
  libraries.knockoutValidation = false
  console.log 'knockout validation is not referenced or is referenced after cyclops some parts of cyclops may not be avalible.'
else
  libraries.knockoutValidation = true

if !moment?
  libraries.moment = false
  console.log 'momentjs is not referenced or is referenced after cyclops some parts of cyclops may not be avalible.'
else
  libraries.moment = true

if !Chartist?
  libraries.chartist = false
  console.log 'chartist is not referenced or is referenced after cyclops some parts of cyclops may not be avalible.'
else
  libraries.chartist = true
