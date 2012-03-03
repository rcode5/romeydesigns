romeyImageData = null;
babyImageData = null
currentSection = null;
$(function() {
  $.getJSON('/pics', function(data) {
    romeyImageData = data;
    var urls = [];
    $.each(data, function() {
      urls.push( this.url.grid );
      urls = urls.reverse();
    });
    $('#main').imageRotator({imageContainer:'.pic', imageUrls: urls, delayMillisec: 3000, fadeDuration: 600});
  });

  $.getJSON('/baby/pics', function(data) {
    babyImageData = data;
    var urls = [];
    $.each(data, function() {
      urls.push( this.url.grid );
      urls = urls.reverse();
    });
    $('#baby').imageRotator({imageContainer:'.pic', imageUrls: urls, delayMillisec: 3000, fadeDuration: 600});
  });

  var updateSection = function(sxn) {
    if (sxn != currentSection) {
      currentSection = sxn;
      $('body').removeClass('baby main event').addClass(sxn);
      $('.nav_links li').removeClass('current');
      $('.nav_links .' + (sxn + '_link')).addClass('current');
    }
  };
  var showMain = function() {
    updateSection('main');
    $('.fullpanel').animate( {'left': '0' }, 1500 );
    return false;
  };
  var showBaby = function() {
    updateSection('baby');
    $('.fullpanel').animate( {'left': '-938' }, 1500 );
    return false;
  };
  var showEvent = function() {
    updateSection('event');
    $('.fullpanel').animate( {'left': '-1876' }, 1500 );
    return false;
  };

  $('.baby_link').bind('click', function() {
    showBaby();
  });

  $('.event_link').bind('click', function() {
    showEvent();
  });

  $('.main_link').bind('click', function() {
    showMain();
  });
    
  $('.event_list .scrollPane').jScrollPane({});
  showMain();
});


