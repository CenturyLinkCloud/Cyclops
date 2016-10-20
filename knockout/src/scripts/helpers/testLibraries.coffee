#test for required libraries
if !ko?
  libraries.knokcout = false
  console.error 'knockout is required, please make sure it is included before the cyclops script.'

if !(ko || {}).validation?
  libraries.knockoutValidation = false
  console.log 'knockout validation is not referenced or is referenced after cyclops some parts of cyclops may not be avalible.'
else
  libraries.knockoutValidation = true
