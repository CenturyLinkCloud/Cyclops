hbs = require('express-hbs')
express = require('express')
env = process.argv[2] || "development"
port = process.env.VCAP_APP_PORT || 4000

module.exports = (app, __base) ->

  app.use express.static(__base + 'assets')

  app.engine 'html', hbs.express4
    partialsDir: __base + 'views/partials'
    layoutDir: __base + 'views/layouts'
    defaultLayout: __base + 'views/layouts/layout.html'
    extname: 'html'

  app.set 'view engine', 'html'
  app.set 'views', __base + 'views'

  app.listen port, ->
    console.log "App running at http://localhost:#{port}"
