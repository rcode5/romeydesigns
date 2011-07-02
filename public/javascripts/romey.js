romeyImageData = null;
$(function() {
  $.getJSON('/pics', function(data) {
    romeyImageData = data;
    var urls = [];
    $.each(data, function() {
      urls.push( this.url.grid );
    });
    $('#main').imageRotator({imageContainer:'.pic', imageUrls: urls});
    $('#main').imageRotator('dump');
  });

  
});