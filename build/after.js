})(this || (0, eval)('this'));

$.holdReady(true);
$.get("/templates/cyclops.tmpl.html", function(tmpl) {
  $("head")
    .append(tmpl);
  $.holdReady(false);
});