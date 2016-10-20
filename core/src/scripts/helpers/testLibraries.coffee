#test for required libraries
if !$?
  libraries.jquery = false
  console.error 'jQuery is required, please make sure it is included before the cyclops script.'

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
