require('coffee-script')
require('coffee-script/register')

__base  = __dirname + '/www/'
app     = require('express')()
config  = require('./config')(app, __base)
routes  = require('./routes')(app, __base)
