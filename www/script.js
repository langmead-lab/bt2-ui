$(".kmer").mouseover(function() {
    var e = document.getElementById("sequence_");
    var kmer = this.id;
    var sequence = e.innerHTML;
    e.innerHTML = sequence.replace(kmer, "<b id = 'highlight'>" + kmer + "</b>");
}); 

$(".kmer").mouseout(function() {
    $('#highlight').contents().unwrap();
});

$(".kmer").click(function() {
    Shiny.setInputValue("kmer_filter", this.id);
});

$(document).on('shiny:inputchanged', function(event) {
    if (event.name === 'font_size_increase') {
        var font_size = $('#kmer_diagram').css('font-size');
        font_size = parseFloat(font_size) + 1;
        $('#kmer_diagram').css('font-size', font_size + 'px');
    }

    if (event.name === 'font_size_decrease') {
        var font_size = $('#kmer_diagram').css('font-size');
        font_size = parseFloat(font_size) - 1;
        $('#kmer_diagram').css('font-size', font_size + 'px');
    }
});
