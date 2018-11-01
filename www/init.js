Shiny.addCustomMessageHandler("jsCode",
    function(message) {
        eval(message.value);
    }
);

$(document).on("shiny:connected", function(event) {
    Shiny.setInputValue("width", window.innerWidth);
});

$(window).resize(function(event) {
    Shiny.setInputValue("width", window.innerWidth);
});
