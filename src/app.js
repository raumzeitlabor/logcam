var app = (function() {
  var lfnClear = function() {
    $('body').empty();
  };
  
  var lfnShowPic = function(ioCanvas) {
    var loCtx = ioCanvas[0].getContext('2d');
    var loImage = new Image();
    loImage.onload = function() {
      loCtx.drawImage(this, 0, 0);
    };
    loImage.src = "http://hackadaycom.files.wordpress.com/2013/08/199163-transcend-16gb-wifi-sd-card-sdhc-class-10.jpg?w=300&h=300";
  }

  var exports = {};
  exports.start = function(ioCanvas) {
    console.log('starting');
    lfnShowPic(ioCanvas);
  };

  return exports;
}(app || {}));

$(document).ready(function() {
  app.start($('#c'));
});
