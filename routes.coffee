fs = require 'fs'

module.exports = (app, __base) ->
  # favicon
  app.get '/favicon.ico', (req, res) ->
    res.status 200
       .end()

  # static pages
  app.get '*', (req, res) ->
    page = req.params[0].replace(/^\/|\/$/g, '') || 'index'
    withoutExtension = __base + '/views/' + page
    withExtension = withoutExtension + '.html'

    fs.stat withExtension, (err, stat) ->
      if err
        fs.stat withoutExtension + '/index.html', (err2, stat2) ->
          if err2
            res.status 404
               .render '404'
          else
            res.render withoutExtension + '/index.html'
      else
        res.render page
