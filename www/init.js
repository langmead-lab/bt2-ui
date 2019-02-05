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
        $(this).val(text);
    });
});
