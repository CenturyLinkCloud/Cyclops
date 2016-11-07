})(this || (0, eval)('this'));

$.holdReady(true);
$.get("/templates/cyclops.tmpl.html", function(tmpl) {
  $("head")
    .append(tmpl);
  $.holdReady(false);
});

// We don't need to hold ready becuase no code is going to error
// if the element isn't there yet, unlike the templates.
var div = $("<div id='cyclopsIcons' style='display:none' aria-hidden='true'></div>")
div.html("<!-- inject:svg --><!-- endinject -->");
$("body").append(div);
