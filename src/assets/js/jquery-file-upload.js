(function($) {
  'use strict';
  if ($("#fileuploader").length) {
    $("#fileuploader").uploadFile({
      url: "/src/assets/images/",
      fileName: "myfile"
    });
  }
})(jQuery);