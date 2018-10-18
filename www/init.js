Shiny.addCustomMessageHandler("jsCode",
    function(message) {
        eval(message.value);
    }
);
