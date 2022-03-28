const OpenMenu = () =>{
    $('body').css("display", "flex")
}

const CloseMenu = () =>{
    $('body').css("display", "none")
}


const updateJobScores = (jobscores) =>{
    let html = ""

    for (let key in jobscores){
        let job = jobscores[key]
        if(job){
            html += `
            <div class="job">
                <i class="${job.icon}"></i>
                <p>${job.players}</p>
            </div>
            `
        }

    }
    $('.jobs').html(html)
}

const updaterobberyscores = (robberyscores, copsnum) =>{
    let html = ""

    for (let key in robberyscores){
        let robbery = robberyscores[key]
        if (robbery){
            let icon = Number(copsnum) >= Number(robbery.score) ? "fa-solid fa-check green" : "fa-solid fa-x red"
            html += `
            <div class="robbery">
                <h2>${robbery.label}</h2>
                <i class="${icon}"></i>
            </div>
            `
        } 
   
    }
    $('.robberies').html(html)
}

document.addEventListener("click", (e) =>{

    if(e.target.classList.contains("close")){
        CloseMenu()
        $.post("http://codem-scoreboard/close");
    }

})


window.addEventListener("message", function (event) {
    var item = event.data;
    switch (item.type) {
        case "open":
            OpenMenu()
            break
        case "close":
            CloseMenu()
            break
        case "updatejobscores":
            updateJobScores(item.jobscores)
            break
        case "updaterobberyscores":
            updaterobberyscores(item.robberyscores, item.copsnum)
            break
        case "updatePlayers":
            $('.players p').text("Players " + item.players+ "/" + item.maxPlayers)
            break
        case "default":
            break
    }
})