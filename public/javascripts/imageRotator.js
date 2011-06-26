// jquery plugin to manage a list of image divs and a list of images
// plugin sets up rotation of the images within the image containers
// 

var imageRotatorDefaults = {};

$.imageRotatorDefaults = {
  imageContainer: '.ir_img_container',
  imageUrls: []
};

var mergeData = function( sel, newData ) {
    $(sel).data($.extend({},$(sel).data(),newData));
};

$.fn.imageRotator = function( method ) {
  var inArgs = arguments;
  var methods = {
    init: function(options) {
      mergeData(this, $.imageRotatorDefaults);
      mergeData(this, options);
    }
  };
  return this.each(function() {
    // If options exist, lets merge them
    // with our default settings
    // Tooltip plugin code here
    // Method calling logic
    if ( methods[method] ) {
      return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else if ( typeof method === 'object' || ! method ) {
      return methods.init.apply( this, inArgs );
    } else {
      $.error( 'Method ' +  method + ' does not exist on jQuery.tooltip' );
    }
  });
};