})(this || (0, eval)('this'));

$.holdReady(true);
$("head").append("<!-- templates:html --><!-- endinject -->");
$.holdReady(false);

// We don't need to hold ready becuase no code is going to error
// if the element isn't there yet, unlike the templates.
var div = $("<div id='cyclopsIcons' style='display:none' aria-hidden='true'></div>")
div.html("<!-- icons:svg --><!-- endinject -->");
$("body").append(div);
