Shiny.addCustomMessageHandler("jsCode",
    function(message) {
        eval(message.value);
    }
);

$(document).on("shiny:connected", function(event) {
    Shiny.setInputValue("width", window.innerWidth);
});


function checkWidgetsForErrors(inputIds, errorTable) {
    var i;
    var widgetHasErrors = false;

    for (i = 0; i < inputIds.length; i++) {
        widgetHasErrors = widgetHasErrors || errorTable[inputIds[i]];
    }

    return widgetHasErrors;
}

var errorTable = {};
$(document).on("shiny:message", function(event) {
    if (event.message.hasOwnProperty("custom")) {
        var custom = event.message.custom;

        if (!custom.hasOwnProperty("checkFeedback")) {
            return;
        } else {
            errorTable[custom.checkFeedback.inputId] = custom.checkFeedback.condition;
        }
    }

    var crisprInputIds = ["crisprSequence"];
    var btInputIds = Object.keys(errorTable).filter(function(inputId) {
        return !(inputId in crisprInputIds);
    });

    var disableBt2Submit = checkWidgetsForErrors(btInputIds, errorTable);
    var disableCrisprSubmit = checkWidgetsForErrors(crisprInputIds, errorTable);
    console.log(disableCrisprSubmit);

    $("#submit").prop("disabled", disableBt2Submit);
    $("#crisprSubmit").prop("disabled", disableCrisprSubmit);
});

$(window).resize(function(event) {
    Shiny.setInputValue("width", window.innerWidth);
});

$(document).ready(function() {
    $("textarea").on('input', function(event) {
        var text = $(this).val().split("\n")[0];
        text = text.replace(/\s|[^ACTGN]/g, "");
        $(this).val(text);
    });
});

// https://stackoverflow.com/a/3701328
$.fn.scrollEnd = function(callback, timeout) {
  $(this).scroll(function(){
    var $this = $(this);
    if ($this.data('scrollTimeout')) {
      clearTimeout($this.data('scrollTimeout'));
    }
    $this.data('scrollTimeout', setTimeout(callback,timeout));
  });
};

$(document).ready(function (event) {
  var top = $('#main').offset().top - parseFloat($('#main').css('marginTop').replace(/auto/, 0));

  $(window).scrollEnd(function (event) {
    var y = $(this).scrollTop();

    var difference = y - top;
    difference = y < top ? 0 : difference;
    $("#main").stop().animate({"top": difference}, 400, "linear");
  }, 250);
});

function loadSam() {
  var e = $('div[data-value="SAM Output"]')[0];
  if (e.scrollTop >= (e.scrollHeight - e.offsetHeight)) {
    Shiny.setInputValue("scrolledToBottom", Math.random());
    e.scrollTop = e.scrollHeight;
  }
}

Shiny.addCustomMessageHandler("samRecords", function(message) {
  $("#crispr_output > .highlight > pre").append(message);
});
