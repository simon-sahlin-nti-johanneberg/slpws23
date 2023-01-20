/* -------------------------------------------------------------------------- */
/*                           HIDING AND SHOWING NAV                           */
/* -------------------------------------------------------------------------- */
scrollpos = window.scrollY;

const topnav = document.querySelector(".topnav")
var titleImg = document.querySelector("#titlepage");
title_height = 0
if(titleImg){
    title_height = titleImg.offsetHeight - 200
}else{
    topnav.classList.add('topnav-opaque')
}


scrollstart = window.scrollY;
scrolldirection = 1;
hideheight = title_height + 500
hidedistance = 300;

window.addEventListener('scroll', function() { 

    if (toggle){ //Guard clause
        return
    }

    if (!((this.window.scrollY - scrollpos) * scrolldirection >= 0)){
        scrolldirection = scrolldirection * -1
        scrollstart = window.scrollY
    }

    scrollpos = window.scrollY;


    if (scrollpos >= hideheight && -1*(scrollstart - scrollpos) > hidedistance)
        topnav.classList.add('topnav-hidden')
    if (scrollstart - scrollpos > hidedistance)
        topnav.classList.remove('topnav-hidden')


    if (scrollpos >= title_height) {  
        topnav.classList.add('topnav-opaque')
    }
    else { 
        topnav.classList.remove('topnav-opaque')
        topnav.classList.remove('topnav-hidden')
    }

})


/* -------------------------------------------------------------------------- */
/*                            BURGER MENU ON MOBILE                           */
/* -------------------------------------------------------------------------- */

const burger = document.querySelector('.burger')
const nav = document.querySelector('.topnav-links')

toggle = false

function toggleMenu() {
    toggle = !toggle
    nav.classList.toggle('topnav-active')
    burger.classList.toggle('burger-active')

    if (toggle){
        topnav.classList.add('topnav-opaque')
    }
    else if(scrollpos < title_height){
        topnav.classList.remove('topnav-opaque')
    }
}

burger.addEventListener('click', toggleMenu)