/* admin js */
$(function() {
  $('a.test_map').bind('click', function() {
    var testaddr = $('input#event_address', $(this).closest('form')).val();
    if (testaddr.length) {
      window.open('http://maps.google.com/maps?q='+escape(testaddr));
    }
  });
  
  $('.editable .value').editable('/event/update_attr');

});