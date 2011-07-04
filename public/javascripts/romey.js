romeyImageData = null;
$(function() {
  $.getJSON('/pics', function(data) {
    romeyImageData = data;
    var urls = [];
    $.each(data, function() {
      urls.push( this.url.grid );
    });
    $('#main').imageRotator({imageContainer:'.pic', imageUrls: urls, delayMillisec: 3000, fadeDuration: 600});
  });
  
});
