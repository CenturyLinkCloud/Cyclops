#test for required libraries
if !$?
  libraries.jquery = false
  console.error 'jQuery is required, please make sure it is included before the cyclops script.'

if !ko?
  libraries.knokcout = false
  console.error 'knokcout is required, please make sure it is included before the cyclops script.'

#test for optional libraries
if !$.ui?
  libraries.jqueryUi = false;
  console.log 'jQuery UI is not referenced or is referenced after cyclops some parts of cyclops may not be avalible.'

if !ko.validation?
  libraries.knockoutValidation = false;
  console.log 'knockout validation is not referenced or is referenced after cyclops some parts of cyclops may not be avalible.'
