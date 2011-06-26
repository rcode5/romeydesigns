require('/javascripts/imageRotator.js');
describe('image rotator jquery plugin', function() {
  template('image_rotator.html');
  describe('init', function() {
    beforeEach(function() {
      $('.images_container').imageRotator({imageContainer:'.blurp'});
    });
    it('puts settings in the data field of element it was called on', function() {
      expect($('.images_container').data()).toEqual({imageContainer:'.blurp'});

    });
    it('manages separate settings for separate instances', function() {
      $('.images_container2').imageRotator({imageContainer:'.blop'});
      expect($('.images_container').data().imageContainer).toEqual('.blurp');
      expect($('.images_container2').data().imageContainer).toEqual('.blop');
    });
  });
});