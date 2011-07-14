(function( $ ){
  $.fn.proxySubmit = function($proxy) {
    var $submit = this;
    $submit.hide();
    $proxy.click(function(){
      if(!$proxy.hasClass('disabled')){
        $submit.click();
      }
      return false;
    });
    return this;
  };
}( jQuery ));

(function( $ ){
  $.fn.stepsFor = function($wizard) {
    var $steps = this,
        $children = $steps.children("li");

    $wizard.bind("onSlide", function(event, position){
      $children.removeClass('active');
      $children.eq(position).addClass('active');
    });

    return this;
  };
}( jQuery ));

(function( $ ){

  var $viewport, $ol, $panels, $wizard,
      $next, $back,
      pos = 0,
      methods = {
        init: function($wzrd){
          $wizard = $wzrd;
          $viewport = $(".viewport");
          $ol = $viewport.find('ol');
          $panels = $(".viewport > ol > li");

          methods.setupSlider();
        },
        setupSlider: function(){
          $panels.css('float', 'left');

          methods.addNavigation();
          methods.addSubmitLink();
          methods.captureTabs();
          methods.resizePanels();

          $(window).resize(methods.resizePanels);
        },
        resizePanels: function(){
          $ol.width(($panels.size() + 1 ) * $viewport.width());
          $panels.css('width', $viewport.width());
          $ol.css('margin-left', methods.calculateMarginFor(pos));
        },
        addNavigation: function(){
          $next = $(document.createElement('input')).addClass('next').attr({'type':'button','value':'Next \u2192'}).appendTo($wizard);
          $back = $(document.createElement('input')).addClass('back').attr({'type':'button','value':'\u2190 Back'}).appendTo($wizard);
          $back.attr('disabled','disabled');

          $wizard.bind("onLastSlideIn", function(){ methods.disableButton($next); });
          $wizard.bind("onLastSlideOut", function(){ methods.enableButton($next); });

          $wizard.bind("onFirstSlideIn", function(){ methods.disableButton($back); });
          $wizard.bind("onFirstSlideOut", function(){ methods.enableButton($back); });

          $(".back").click(function(){
            if($(this).is(":enabled")){ methods.slide("left"); }
          });

          $(".next").click(function(){
            if($(this).is(":enabled")){ methods.slide("right"); }
          });
        },
        captureTabs: function(){
          $panels.find(".element:last input:last,select:last").bind('keydown', function(e){
            if (e.keyCode === 9 && !e.shiftKey) {
              methods.slide("right");
              e.preventDefault();
            }
          });

          $panels.find(".element:first input:first,select:first").bind('keydown', function(e){
            if (e.keyCode === 9 && e.shiftKey) {
              methods.slide("left");
              e.preventDefault();
            }
          });

          $panels.bind('slideIn', function(e){
            $(this).find("input:first").focus();
          });
        },
        addSubmitLink: function(){
          $(document.createElement('a')).attr({'href':'#'}).addClass('disabled').html("Complete Purchase").appendTo("#checkout-now.disabled");
        },
        slide: function(direction){
          switch(direction){
            case "left":
              if(pos === 0){ return; }
              $panels.eq(pos).trigger("slideOut");
              if(pos === $panels.length - 1){ $wizard.trigger("onLastSlideOut", [ pos ] ); }

              pos--;

              $ol.animate({marginLeft: methods.calculateMarginFor(pos) }, 'fast', function(){
                $panels.eq(pos).trigger("slideIn");
                if(pos === 0){ $wizard.trigger("onFirstSlideIn", [ pos ] ); }
              });
              break;
            case "right":
              if(pos === $panels.length - 1) { return; }
              $panels.eq(pos).trigger("slideOut");
              if(pos === 0){ $wizard.trigger("onFirstSlideOut", [ pos ] ); }

              pos++;

              $ol.animate({marginLeft: methods.calculateMarginFor(pos) }, 'fast', function(){
                $panels.eq(pos).trigger("slideIn");
                if(pos === $panels.length - 1){ $wizard.trigger("onLastSlideIn", [ pos ] ); }
              });
              break;
            default:
              return;
          }
          $wizard.trigger("onSlide", [ pos ] );
        },
        enableButton: function($btn){
          $btn.removeAttr('disabled');
        },
        disableButton: function($btn){
          $btn.attr('disabled','disabled');
        },
        calculateMarginFor: function(pos){
          return -($viewport.width() * pos);
        },
        position: function(){
          return pos;
        }

      };

  $.fn.slidingWizard = function() {
    methods.init(this);
    return this;
  };
}( jQuery ));

$(document).ready(function(){
  $wizard = $(".sliding-wizard");
  $wizard.slidingWizard();

  $("#steps").stepsFor($wizard);

  $('.sliding-wizard :submit').proxySubmit($("#checkout-now a"));
  $wizard.bind("onLastSlideIn", function(){
    $("#checkout-now, #checkout-now a").removeClass("disabled");
  });
  $wizard.bind("onLastSlideOut  ", function(){
    $("#checkout-now, #checkout-now a").addClass('disabled');
  });

  $wizard.bind("onLastSlideIn", function(){
    updateConfirmation();
  });
});

// Tech Debt
function updateConfirmation(){
  $confirmation = $("#confirmation");

  $("#confirmation-title").remove();
  $("#customer-confirmation").remove();
  $("#credit_card-confirmation").remove();
  $("#billing_address-confirmation").remove();

  $(document.createElement('h3')).attr('id','confirmation-title').html("Confirmation").prependTo($confirmation);

  $(document.createElement('div')).attr('id','customer-confirmation').appendTo($confirmation);
  $(document.createElement('div')).attr('id','credit_card-confirmation').appendTo($confirmation);
  $(document.createElement('div')).attr('id','billing_address-confirmation').appendTo($confirmation);


  $(document.createElement('h4')).html("Customer Information").appendTo($("#customer-confirmation"));
  var customer = $("#customer").find("input:visible, select").serializeArray();
  $.each(customer, function(i,field){
    key = field.name.match(/\]\[(.*)\]$/)[1].replace(/_/,' ');
    value = field.value;
    $(document.createElement('p')).html(key + ": " + value).appendTo($("#customer-confirmation"));
  });

  var creditCard = $("#credit_card").find("input:visible, select").serializeArray();
  if (creditCard.length > 0){
      $(document.createElement('h4')).html("Credit Card Information").appendTo($("#credit_card-confirmation"));
  }

  var expiration = [];
  $.each(creditCard, function(i,field){
    key = field.name.match(/\]\[(.*)\]$/)[1].replace(/_/,' ');
    value = field.value;
    if(!key.match(/(\di)/)){
      $(document.createElement('p')).html(key + ": " + value).appendTo($("#credit_card-confirmation"));
    } else {
      expiration.push(value);
    }
  });

  if(expiration.length > 0){
    $(document.createElement('p')).html("Expiration: " + expiration[0] + "/" + expiration[1]).appendTo($("#credit_card-confirmation"));
  }

  $(document.createElement('h4')).html("Billing Address").appendTo($("#billing_address-confirmation"));
  var address = $("#billing_address").find("input:visible, select").serializeArray();
  $.each(address, function(i,field){
    key = field.name.match(/\]\[(.*)\]$/)[1].replace(/_/,' ');
    value = field.value;
    $(document.createElement('p')).html(key + ": " + value).appendTo($("#billing_address-confirmation"));
  });

  $(document.createElement('input')).attr({'type':'hidden', 'name':'confirmation','value':'1'}).appendTo($("#billing_address-confirmation"));
}