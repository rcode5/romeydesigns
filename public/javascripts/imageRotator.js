// jquery plugin to manage a list of image divs and a list of images
// plugin sets up rotation of the images within the image containers
// 

var imageRotatorDefaults = {};

$.imageRotatorDefaults = {
  imageContainer: '.ir_img_container',
  imageUrls: [],
  delayMillisec: 5000,
  fadeDuration: 500
};

var mergeData = function( sel, newData ) {
  $(sel).data($.extend({},$(sel).data(),newData));
};

$.fn.imageRotator = function( method ) {
  var inArgs = arguments;
  var methods = {
    init: function(options) {
      this.imageQ = new Queue();
      this.counter = 0;
      mergeData(this, $.imageRotatorDefaults);
      mergeData(this, options);
      this.delayMillisec = options.delayMillisec;
      this.fadeDuration = options.fadeDuration;
      var urls = $(this).data().imageUrls;
      var ii = 0;
      var nurls = urls.length;
      for (;ii < nurls; ++ii ) {
        this.imageQ.enqueue(urls[ii]);
      };
      var rotateable = $(this).find(options.imageContainer + " img");
      ii = 0;
      var nrotatable = rotateable.length;
      var _that = this;
      setTimeout(function(){ $(_that).imageRotator('updateImage'); }, _that.delayMillisec );
    },
    dump: function() {
      console.log('queue size: ', this.imageQ.getLength());
    },
    updateImage: function() {
      var nextImage = this.imageQ.dequeue();
      this.imageQ.enqueue(nextImage);
      var $this = $(this)
      var rotateable = $this.find($this.data().imageContainer + " img");
      var nrotateable = rotateable.length;
      var img = rotateable[ this.counter % nrotateable];
      var _that = this;
      $(img).fadeOut(this.fadeDuration, function() {
        this.src = nextImage;
        $(this).fadeIn(_that.fadeDuration);
      });
      this.counter+=1;
      setTimeout(function(){ $this.imageRotator('updateImage'); }, this.delayMillisec );
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