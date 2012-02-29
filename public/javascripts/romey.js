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

  $('.event_link').bind('click', function() {
    var cur_left = $('.fullpanel').position().left;
    if (!cur_left || (cur_left > -900)) {
      $('.fullpanel').animate( {'left': '-938'}, 1500 );
    }
    else {
      $('.fullpanel').animate( {'left': '0' }, 1500 );
    }
    return false;
  });

  $('.event_list .scrollPane').jScrollPane({});
});


