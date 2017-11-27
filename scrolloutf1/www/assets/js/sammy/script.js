
;(function($) {
  var app = $.sammy(function() {


    this.post('connection_nxt.php', function(){
      showLoading();
      $.post("api/api_connection.php", $("#page_form").serialize(), function(response){
        console.log(response.msg);
          $("#button_save").show();
          $("#apply_loading").hide();
          new PNotify({
                title: 'Succes',
                text: 'Saved and applied changes successfuly',
                type: 'success',
                styling: 'bootstrap3'
            });
      });
    });

    this.post('collector_nxt.php', function(){
      var hasError = getError();
      console.log(hasError);
      if(hasError && hasError.length){
        for(i=0; i<hasError.length; i++){
          if(hasError[i])
            new PNotify({
                  title: 'Error',
                  text: 'Please check the errors',
                  type: 'error',
                  styling: 'bootstrap3'
              });
            return;
        }
      }
      else{
        showLoading();
        $.post("api/api_collector.php", $("#page_form").serialize(), function(response){
          // console.log(response.msg);
            $("#button_save").show();
            $("#apply_loading").hide();
            new PNotify({
                  title: 'Succes',
                  text: 'Saved and applied changes successfuly',
                  type: 'success',
                  styling: 'bootstrap3'
              });
        });
      }
    })

    this.post('monitor_nxt.php', function(){
      showLoading();
      $.post("api/api_logs.php", $("#page_form").serialize(), function(response){
        console.log(response.msg);
          $("#button_save").show();
          $("#button_clear_filter").show();
          $("#apply_loading").hide(); 
          $("#responsecontainer").load('logsreload.html?randval='+ Math.random(),function(){
            $("#responsecontainer").animate({
            scrollTop: $('#responsecontainer')[0].scrollHeight - $('#responsecontainer')[0].clientHeight
          }, 500);
          });
      });
    })

    this.post('traffic_nxt.php', function(){
      showLoading();
      $.post("api/api_traffic.php", $("#page_form").serialize(), function(response){
        // console.log(response.msg);
          $(".button_save").show();
          
          $(".apply_loading").hide();
          new PNotify({
                title: 'Succes',
                text: 'Saved and applied changes successfuly',
                type: 'success',
                styling: 'bootstrap3'
            });
      });
    })

    this.post('connection_nxt.php#/certs', function(){
      showLoading();
      $.post("api/api_cert.php", $("#page_form_certificates").serialize(), function(response){
        // console.log(response.msg);
          $(".button_save").show();
          
          $(".apply_loading").hide();
          new PNotify({
                title: 'Succes',
                text: 'Saved and applied changes successfuly',
                type: 'success',
                styling: 'bootstrap3'
            });
      });
    })  

    this.post('connection_nxt.php#/pwd', function(){
      showLoading();
      $.post("api/api_pwd.php", $("#page_form_password").serialize(), function(response){
         
          $(".button_save").show();
          
          $(".apply_loading").hide();
          var result  = JSON.parse(response);
          if(result.type == "error"){
            new PNotify({
                title: 'Error',
                text: result.msg,
                type: 'error',
                styling: 'bootstrap3'
            });
          }else{
            new PNotify({
                title: 'Succes',
                text: result.msg,
                type: 'success',
                styling: 'bootstrap3'
            });
          }
          
      });
    })    

    this.post('connection_nxt.php#/senders', function(){
      showLoading();
      $.post("api/api_senders.php", $("#page_form_senders").serialize(), function(response){
        // console.log(response.msg);
          $(".button_save").show();
          
          $(".apply_loading").hide();
          new PNotify({
                title: 'Succes',
                text: 'Saved and applied changes successfuly',
                type: 'success',
                styling: 'bootstrap3'
            });
      });
    })

    this.post('connection_nxt.php#/levels', function(){
      showLoading();
      $.post("api/api_securities.php", $("#page_form_levels").serialize(), function(response){
        // console.log(response.msg);
          $(".button_save").show();
          
          $(".apply_loading").hide();
          new PNotify({
                title: 'Succes',
                text: 'Saved and applied changes successfuly',
                type: 'success',
                styling: 'bootstrap3'
            });
      });
    })

    this.post('connection_nxt.php#/reputation', function(){
      showLoading();
      $.post("api/api_reputation.php", $("#reputation_form").serialize(), function(response){
        // console.log(response.msg);
          $(".button_save").show();
          
          $(".apply_loading").hide();
          new PNotify({
                title: 'Succes',
                text: 'Saved and applied changes successfuly',
                type: 'success',
                styling: 'bootstrap3'
            });
      });
    })

    this.post('connection_nxt.php#/countries', function(){
      showLoading();
      $.post("api/api_countries.php", $("#page_form_countries").serialize(), function(response){
        // console.log(response.msg);
          $(".button_save").show();
          
          $(".apply_loading").hide();
          new PNotify({
                title: 'Succes',
                text: 'Saved and applied changes successfuly',
                type: 'success',
                styling: 'bootstrap3'
            });
      });
    })





    this.get('#/', function() {
      hideAll();
      $('#main').text('Config');
    });


    this.get('#/connect/configure', function(){
    })



    this.get('#/traffic/config', function(){
      hideAllTraffic("config");
      $(".default-view").removeClass('default-view');
      hideCurrentSectionMenu();
    })

    this.get('#/traffic/:domain_md5/:page', function(){
      if(this.params['page'] == 'remove'){
        if (confirm("Are you sure you want to delete this domain?") == true) {
          remove("page-traffic-domain-"+this.params["domain_md5"]+"-general", false);
          remove("page-traffic-domain-"+this.params["domain_md5"]+"-quarantine", false);
          remove("page-traffic-domain-"+this.params["domain_md5"]+"-inbound", false);
          remove("page-traffic-domain-"+this.params["domain_md5"]+"-outbound", false);
          remove("li-"+this.params["domain_md5"], true); 
          $( document ).ready(function() {submitSettings();});
        }
      }
      else{
        hideAllTraffic("domain-"+this.params['domain_md5']+"-"+this.params['page']);
        $(".default-view").removeClass('default-view');
        hideCurrentSectionMenu();
        // $('.page-header').text(this.params['action'] + ' for ' + this.params['domain_no']);
      }
    })

    this.get('#/traffic', function(){
      hideAllTraffic(false);
      $("#page-traffic-config").addClass('default-view');
      showCurrentSectionMenu();
    })







    this.get('#/security/:page', function(){
      hideAllSecurity(this.params['page']);
      $(".default-view").removeClass('default-view');
      hideCurrentSectionMenu();
    })

    this.get('#/security', function(){
      hideAllSecurity(false);
      $("#page-security-levels").addClass('default-view');
      showCurrentSectionMenu();
    })








    this.get('#/monitor/:page', function(){
      hideAllMonitor(this.params['page']);
      $(".default-view").removeClass('default-view');
      hideCurrentSectionMenu();
    })

    this.get('#/monitor', function(){
      hideAllMonitor(false);
      $("#page-monitor-logs").addClass('default-view');
      showCurrentSectionMenu();
    })






    







    this.get('collector_nxt.php', function(){
        hideCurrentSectionMenu();
    })







    this.notFound = function(){
      console.log('Sammy info: unknown route, but it\'s ok');
    }
  });
  $(function() {
    app.run()
  });
})(jQuery);








function hideAll(){

}

function hideAllSecurity(except){
  $("#page-security-levels").hide();
  $("#page-security-senders").hide();
  $("#page-security-reputation").hide();
  $("#page-security-countries").hide();
  $("#page-security-certificate").hide();
  $("#page-security-password").hide();
  if(except){
    $("#page-security-"+except).show();
  }
}
hideAllSecurity(false);


function hideAllMonitor(except){
  $("#page-monitor-logs").hide();
  $("#page-monitor-graph").hide();
  if(except){
    $("#page-monitor-"+except).show();
  }  
}
hideAllMonitor(false);


function hideAllTraffic(except){
  $("#page-traffic-config").hide();
  $("div[id^='page-traffic-domain']").hide();
  if(except){
    $("#page-traffic-"+except).show();
  }    
}
hideAllTraffic(false);










function showLoading(){
  $("#button_save").hide();
  $(".button_save").hide();
  $(".button_clear").hide();
  $("#apply_loading").show();
  $(".apply_loading").show();
}








function showCurrentSectionMenu(){
  $(".sidebar").removeClass("hidden-xs");
}

function hideCurrentSectionMenu(){
  // $(".sidebar").addClass("sidebar-out");
  $(".sidebar").addClass("hidden-xs");
}


function remove(id, slowHide) {
    if(slowHide){
      $("#"+id).hide('fast',function(){
        console.log(this);
        var elem = document.getElementById(this.id);
        if(elem)elem.parentNode.removeChild(elem);
      });
    }
    else{
      var elem = document.getElementById(id);
      if(elem)elem.parentNode.removeChild(elem);
    }
}
