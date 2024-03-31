$(document).ready(function () {
    $("#container").hide();
    window.addEventListener('message', function (event) {
        switch (event.data.action) {
            case "open":
                $("#container").fadeIn(500);
        }
    })
});

function StartHeist() {
    $('#container').fadeOut(500);
    $.post('https://ac-yacht-heist/ac-yacht-heist:client:StartHackingPreperation')
}

function CloseHeistMenu() {
    $("#container").fadeOut(500);
    $.post('https://ac-yacht-heist/ac-yacht-heist:client:CloseMenuHeist')
}