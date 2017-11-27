var cssId = 'stylesheet_day';

function goTo(link){
	window.location.href = link;
	$.get("/customizer/","click="+link);
}

function toggleNightmode(checkbox){
	if (!checkbox.checked)
	{
	    var head  = document.getElementsByTagName('head')[0];
	    var link  = document.createElement('link');
	    link.id   = cssId;
	    link.rel  = 'stylesheet';
	    link.type = 'text/css';
	    link.href = 'assets/css/style_day.css';
	    link.media = 'all';
	    head.appendChild(link);
	    nxt_createCookie("nightmode","false",9999999);
	}
	else{
		try{
			document.getElementById(cssId).remove();
		}
		catch(e){
			console.log("Info: Day css not found. Not removing. It's ok.");
		}
		nxt_createCookie("nightmode","true",9999999);
	}
}


function nxt_createCookie(name,value,days) {
    if (days) {
        var date = new Date();
        date.setTime(date.getTime()+(days*24*60*60*1000));
        var expires = "; expires="+date.toGMTString();
    }
    else var expires = "";
    document.cookie = name+"="+value+expires+"; path=/";
}

function nxt_readCookie(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for(var i=0;i < ca.length;i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1,c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
    }
    return null;
}


function setNightmode(){
	if (nxt_readCookie("nightmode") == "false")
	{
	    var head  = document.getElementsByTagName('head')[0];
	    var link  = document.createElement('link');
	    link.id   = cssId;
	    link.rel  = 'stylesheet';
	    link.type = 'text/css';
	    link.href = 'assets/css/style_day.css';
	    link.media = 'all';
	    head.appendChild(link);
	}
	else{
		$('#nightmode_toggle').click();
	}
}

window.onload = function() {
	setNightmode();
};

function validateEmail(email) {
    var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
}












var hasError = [];

function getError(){
    return hasError;
}
function addError(err){
    if(!hasError.includes(err)){
        hasError.push(err);
    }
    console.log("Added Error " + hasError);
}
function removeError(err){
    for(var i = hasError.length; i--;) {
          if(hasError[i] === err) {
              hasError.splice(i, 1);
          }
      }
    console.log("Removed Error " + hasError);
}

























var CURRENT_URL = window.location.href.split('?')[0],
    $BODY = $('body'),
    $MENU_TOGGLE = $('#menu_toggle'),
    $SIDEBAR_MENU = $('#sidebar-menu'),
    $SIDEBAR_FOOTER = $('.sidebar-footer'),
    $LEFT_COL = $('.left_col'),
    $RIGHT_COL = $('.right_col'),
    $NAV_MENU = $('.nav_menu'),
    $FOOTER = $('footer');

var setContentHeight = function () {
    // reset height
    $RIGHT_COL.css('min-height', $(window).height());

    var bodyHeight = $BODY.outerHeight(),
        footerHeight = $BODY.hasClass('footer_fixed') ? -10 : $FOOTER.height(),
        leftColHeight = $LEFT_COL.eq(1).height() + $SIDEBAR_FOOTER.height(),
        contentHeight = bodyHeight < leftColHeight ? leftColHeight : bodyHeight;

    // normalize content
    contentHeight -= $NAV_MENU.height() + footerHeight;

    $RIGHT_COL.css('min-height', contentHeight);
};

function menuSetup(){
    $SIDEBAR_MENU.find('a').off('click');
    $SIDEBAR_MENU.find('a').on('click', function(ev) {
        var $li = $(this).parent();


        if ($li.is('.active')) {
            $li.removeClass('active active-sm');
            $($li[0]).children().children(".fa-chevron-down").removeClass('open');
            $('ul:first', $li).slideUp(function() {
                setContentHeight();
            });
        } else {
            // prevent closing menu if we are on child menu
            if (!$li.parent().is('.child_menu')) {
                $SIDEBAR_MENU.find('li').removeClass('active active-sm');
                $SIDEBAR_MENU.find('li ul').slideUp();
                $(".fa-chevron-down").removeClass('open');
            }
            $($li[0]).children().children(".fa-chevron-down").addClass('open');
            $li.addClass('active');

            $('ul:first', $li).slideDown(function() {
                setContentHeight();
            });
        }
    });

    $SIDEBAR_MENU.find('li ul').slideUp();
}

// Sidebar
$(document).ready(function() {
    // TODO: This is some kind of easy fix, maybe we can improve this


    menuSetup();

    // toggle small or large menu
    $MENU_TOGGLE.on('click', function() {
        if ($BODY.hasClass('nav-md')) {
            $SIDEBAR_MENU.find('li.active ul').hide();
            $SIDEBAR_MENU.find('li.active').addClass('active-sm').removeClass('active');
        } else {
            $SIDEBAR_MENU.find('li.active-sm ul').show();
            $SIDEBAR_MENU.find('li.active-sm').addClass('active').removeClass('active-sm');
        }

        $BODY.toggleClass('nav-md nav-sm');

        setContentHeight();
    });

    // check active menu
    $SIDEBAR_MENU.find('a[href="' + CURRENT_URL + '"]').parent('li').addClass('current-page');

    $SIDEBAR_MENU.find('a').filter(function () {
        return this.href == CURRENT_URL;
    }).parent('li').addClass('current-page').parents('ul').slideDown(function() {
        setContentHeight();
    }).parent().addClass('active');

    // recompute content when resizing
    // $(window).smartresize(function(){  
    //     setContentHeight();
    // });

    setContentHeight();

    // fixed sidebar
    if ($.fn.mCustomScrollbar) {
        $('.menu_fixed').mCustomScrollbar({
            autoHideScrollbar: true,
            theme: 'minimal',
            mouseWheel:{ preventDefault: true }
        });
    }

});
// /Sidebar


// Tooltip
$(document).ready(function() {
    $('[data-toggle="tooltip"]').tooltip({
        container: 'body'
    });

});
// /Tooltip

// Switchery
$(document).ready(function() {
    if ($(".js-switch")[0]) {
        var elems = Array.prototype.slice.call(document.querySelectorAll('.js-switch'));
        elems.forEach(function (html) {
            var switchery = new Switchery(html, { color: '#04acec', jackColor: '#fff' });
        });
    }
    //$('.coloreveryother').on('click', toggleChevron);
	$("div[data-toggle='collapse']").on('click', toggleChevron);
	 
});
// /Switchery


// Fullscreen

function launchFullscreen(element) {
  if(element.requestFullscreen) {
    element.requestFullscreen();
  } else if(element.mozRequestFullScreen) {
    element.mozRequestFullScreen();
  } else if(element.webkitRequestFullscreen) {
    element.webkitRequestFullscreen();
  } else if(element.msRequestFullscreen) {
    element.msRequestFullscreen();
  }
}

// /Fullscreen


// Chevron rotate on collapse or expand

function toggleChevron(e) {
  /*$(e.currentTarget)
      .children(0).children(0).children(0).children(".section-chevron")
      .toggleClass('open');*/
   
  var current = $(e.currentTarget);
  var chev = $(current[0]).children(); 
  $(chev[1]).toggleClass("open");
}

// $('.coloreveryother').on('hidden.bs.collapse', toggleChevron);                       //These commented ones are equivalent with "onCollapseAnimationEnd"
// $('.coloreveryother').on('shown.bs.collapse', toggleChevron);
// $('.coloreveryothersecond').on('hidden.bs.collapse', toggleChevron);
// $('.coloreveryothersecond').on('shown.bs.collapse', toggleChevron);

// /Chevron rotate on collapse or expand
