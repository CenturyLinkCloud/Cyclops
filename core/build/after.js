})(this || (0, eval)('this'));

// We don't need to hold ready becuase no code is going to error
// if the element isn't there yet, unlike the templates.
$.get("/svg/cyclops.icons.svg", function(data) {
  var div = $("<div id='cyclopsIcons' style='display:none' aria-hidden='true'></div>")
  div.html(new XMLSerializer().serializeToString(data.documentElement));
  $("body").append(div);
});
