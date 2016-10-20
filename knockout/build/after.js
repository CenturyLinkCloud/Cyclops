})(this || (0, eval)('this'));


$.holdReady(true);
$.get("/templates/cyclops.knockout.tmpl.html", function(tmpl) {
  $("head")
    .append(tmpl);
  $.holdReady(false);
});
