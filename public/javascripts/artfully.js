(function(window, document, undefined){
  window.artfully = {};
  window.artfully.config = {};

  artfully.configure = function(obj){
    jQuery.extend(artfully.config, obj);
  };

  artfully.alert = function(msg){
    jQuery("#artfully-alert").fadeOut('fast',function(){
      jQuery(this).html(msg);
      jQuery(this).fadeIn('slow');
    });
  };
}(this, document));

artfully.config = {
  base_uri: 'http://api.lvh.me:3000/',
  store_uri: 'http://localhost:3000/store/',
  maxHeight: '350'
};

artfully.utils = (function(){
  function ticket_uri(params){
    var u = artfully.config.base_uri + 'tickets.jsonp?callback=?';
    jQuery.each(params, function(k,v){
      u += "&" + k + "=" + v;
    });
    return u;
  }

  function event_uri(id){
    return artfully.config.base_uri + 'events/' + id + '.jsonp?callback=?';
  }

  function performance_uri(id){
    return artfully.config.base_uri + 'performances/' + id + '.jsonp?callback=?';
  }

  function order_uri(){
    return artfully.config.store_uri + 'order';
  }

  function donation_uri(id){
    return artfully.config.base_uri + 'organizations/' + id + '/authorization.jsonp?callback=?';
  }

  function keyOnId(list){
    var result = {};
    jQuery.each(list, function(index, item){
      result[item.id] = item;
    });
    return result;
  }

  function modelize(data, model, callback){
    if(data){
      if(data instanceof Array){
        jQuery.each(data, function(index, item){
          modelize(item, model, callback);
        });
      } else {
        jQuery.extend(data,model());
        if(callback !== undefined){
          callback(data);
        }
      }
    }
    return data;
  }

  return {
    ticket_uri: ticket_uri,
    performance_uri: performance_uri,
    event_uri: event_uri,
    donation_uri: donation_uri,
    order_uri: order_uri,
    keyOnId: keyOnId,
    modelize: modelize
  };
}());

artfully.widgets = (function(){
  var artfully_event, cart, donation,
      widgetCache = {};

  artfully_event = function(){
    function prep(data){
      var charts = artfully.utils.keyOnId(data.charts);

      // Modelize charts and their sections.
      //artfully.utils.modelize(charts, artfully.models.chart, function(chart){
      //  artfully.utils.modelize(chart.sections, artfully.models.section);
      //});
      //since charts are hashed, we can't pass in the whole hash because modelize expects and Array
      //and we can't check for a hash because it's impossible in javascript
        jQuery.each(charts, function(index, chart){
          	artfully.utils.modelize(chart, artfully.models.chart,
            	function(chart){
        			artfully.utils.modelize(chart.sections, artfully.models.section);
      			}
            );
        });


      // Modelize performance and assign charts.
      artfully.utils.modelize(data.performances, artfully.models.performance, function(performance){
        performance.chart = charts[performance.chart_id];
      });

      return artfully.utils.modelize(data, artfully.models.artfully_event);
    }

    function render(data){
      e = prep(data);
      e.render(jQuery('#event'));
    }

    if(widgetCache.artfully_event === undefined){
      widgetCache.artfully_event = {
        display: function(id){
          artfully.widgets.cart().display();
          jQuery.getJSON(artfully.utils.event_uri(id), function(data){
            render(data);
          });
        }
      };
    }

    return widgetCache.artfully_event;
  };
  cart = function(){
    function hiddenFormFor(tickets){
      var $form = jQuery(document.createElement('form')).attr({'method':'post','target':artfully.widgets.cart().$iframe.attr('name'), 'action':artfully.utils.order_uri()});

      jQuery.each(tickets, function(i,ticket){
        jQuery(document.createElement('input')).attr({'type':'hidden', 'name':'tickets[]','value':ticket.id}).appendTo($form);
      });

      return $form.appendTo(jQuery('body'));
    }

    // This is our ShoppingCart object.
    var internal_cart = {
      init: function(){
        this.$cart = jQuery("<div id='shopping-cart' class='hidden' />");

        this.$controls = jQuery("<div id='shopping-cart-controls' />").appendTo(this.$cart);
        // jQuery("<span class='timer' />").text("(Countdown)").appendTo(this.$controls);
        jQuery("<span class='cart-name' />").text("Shopping Cart").appendTo(this.$controls);

        this.$iframe = jQuery("<iframe name='shopping-cart-iframe' />")
                        .attr('src',artfully.utils.order_uri())
                        .height(artfully.config.maxHeight)
                        .hide()
                        .appendTo(this.$cart);

        return this.$cart;
      },

      display: function(){
        this.$cart.appendTo('body');
      },

      add: function(tickets){
        hiddenFormFor(tickets).submit().remove();
        this.show();
      },

      show: function(){
        this.$cart.addClass('shown').removeClass('hidden');
        this.$iframe.slideDown();
      },

      hide: function(){
        this.$cart.addClass('hidden').removeClass('shown');
        this.$iframe.slideUp();
      },

      toggle: function(){
        if(this.$cart.hasClass('shown')){
          this.hide();
        } else {
          this.show();
        }
      }
    };

    internal_cart.init();
    internal_cart.$controls.click(function(){ cart().toggle(); });

    if(widgetCache.cart === undefined){
      widgetCache.cart = internal_cart;
    }

    return widgetCache.cart;
  };
  donation = function(){
    function prep(donation){
      return artfully.utils.modelize(donation, artfully.models.donation);
    }
    function authorize(donation){
      jQuery.getJSON(artfully.utils.donation_uri(donation.organizationId), function(data){
        if(data.authorized){
          donation.type = data.type;
          donation.fsp_name = data.fsp_name;
          donation.render(jQuery('#donation'));
        }
      });
    }
    function render(data){
      var donation = prep(data);
      authorize(donation);
    }
    if(widgetCache.donation === undefined){
      widgetCache.donation = {
        display: function(id){
          var data = { organizationId:id };
          render(data);
        }
      };
    }

    return widgetCache.donation;
  };

  return {
    event: artfully_event,
    cart: cart,
    donation: donation
  };
}());

artfully.models = (function(){

  var chart, section, performance, artfully_event, donation
      modelCache = {};

  chart = function(){
    if(modelCache.chart === undefined){
      modelCache.chart = {
        render: function($target, expanded){
          res = this.container().appendTo($target);
          if(expanded == false) { res.hide() }
        },
        container: function(){
          var $c = jQuery(document.createElement('ul')).addClass('sections');

         jQuery.each(this.sections, function(index, section){
           section.render($c);
          });

          return $c;
        }
      };
    }
    return modelCache.chart;
  };

  section = function(){
    if(modelCache.section === undefined){
      modelCache.section = {
        render: function($t){
          this.$target = this.container();
          this.render_info(this.$target);
          this.render_form(this.$target);
          this.$target.appendTo($t);
        },
        container: function(){
          return jQuery(document.createElement('li'));
        },
        render_info: function($target){
          jQuery(document.createElement('span')).addClass('section-name').text(this.name).appendTo($target);
          jQuery(document.createElement('span')).addClass('section-price').text("$" + (new Number(this.price) / 100)).appendTo($target);
        },
        render_form: function($target){
          var $select,
              $form = jQuery(document.createElement('form')).appendTo($target),
              obj = this,
              i;

          $select = jQuery(document.createElement('select')).attr({'name':'ticket_count'}).addClass('ticket_count').appendTo($form);
          jQuery(document.createElement('option')).text("1 Ticket").attr('value', 1).appendTo($select);
          for(i = 2; i <= 10; i++){
            jQuery(document.createElement('option')).text(i + " Tickets").attr('value', i).appendTo($select);
          }

          jQuery(document.createElement('input')).attr('type','submit').val('Go').appendTo($form);

          $form.submit(function(){
            var params = {
              'limit': $select.val(),
              'show_id': jQuery(this).closest('.performance').data('performance').id,
              'price': obj.price
            };

            jQuery.getJSON(artfully.utils.ticket_uri(params), function(data){
              if(data !== null && data.length > 0){
                if(data.length < $select.val()){
                  artfully.alert("Only " + data.length + " ticket(s) could be found for this performance.");
                }
                artfully.widgets.cart().add(data);
                jQuery('.sections').slideUp();
              } else {
                artfully.alert("Sorry! No tickets were available for purchase at this time.");
              }
            });

            return false;
          });
        }
      };
    }
    return modelCache.section;
  };

  performance = function(){
    if(modelCache.performance === undefined){
      modelCache.performance = {
        render: function(target, expanded){
          var $t;
          $t = jQuery(document.createElement('li')).addClass('performance').appendTo(target);
          $t.data('performance', this);

          performance_link = jQuery(document.createElement('a'))
          .addClass('performance-datetime')
          .text(this.show_time)
          .attr("href","#")
          .appendTo($t);
          
          if(expanded == false) {            
            performance_link.click(function(){
              jQuery(this).closest(".performance").children(".sections").slideToggle();
              return false;
            })
          }

          this.chart.render($t, expanded);
          this.$target = $t;
        }
      };
    }
    return modelCache.performance;
  };

  artfully_event = function(){
    if(modelCache.artfully_event === undefined){
      modelCache.artfully_event = {
        render: function($target){
          // Tech Debt: only really need to store the three properties.
          $target.data('event', this);

          $target.append(jQuery(document.createElement('h1')).addClass('event-name').text(this.name))
                .append(jQuery(document.createElement('h3')).addClass('event-producer').text(this.producer));

          this.render_performances($target);
        },
        render_performances: function($target){
          $ul = jQuery(document.createElement('ul')).addClass('performances').appendTo($target);
          
          if(this.performances.length == 1) {
            this.performances[0].render($ul, true)
          } else {
            jQuery.each(this.performances, function(index, performance){
              performance.render($ul, false);
            });
          }
        }
      };
    }
    return modelCache.artfully_event;
  };

  donation = function(){
    if(modelCache.donation === undefined){
      modelCache.donation = {
        message: function($key){
          var messages = {
            'regular': "Help support the show by adding a donation to your order! Contributions are tax-deductible to the extent permitted by law.",
            'sponsored': this.fsp_name + " is a fiscally sponsored project of Fractured Atlas, a non-profit arts service organization. Contributions for the purposes of " + this.fsp_name  + " must be made payable to Fractured Atlas and are tax-deductible to the extent permitted by law."
          };
          return messages[$key] || "";
        },
        render: function($t){
          var $form = jQuery(document.createElement('form')).attr({'method':'post','target':artfully.widgets.cart().$iframe.attr('name'), 'action':artfully.utils.order_uri()}),
              $producer = jQuery(document.createElement('input')).attr({'type':'hidden','name':'donation[organization_id]','value':this.organizationId}),
              $amount = jQuery(document.createElement('input')).attr({'type':'text', 'name':'donation[amount]'}).addClass('currency'),
              $submit = jQuery(document.createElement('input')).attr({'type':'submit', 'value':'Make Donation'}),
              $notice = jQuery(document.createElement('p')).html(this.message(this.type));

          $form.submit(function(){
            artfully.widgets.cart().show();
          });

          $notice.appendTo($t);

          $form.append($amount)
               .append($producer)
               .append($submit)
               .appendTo($t);

          jQuery(".currency").each(function(index, element){
           var name = jQuery(this).attr('name'),
               input = jQuery(this),
               form = jQuery(this).closest('form'),
               hiddenCurrency = jQuery(document.createElement('input'));

           input.maskMoney({showSymbol:true, symbolStay:true, allowZero:true, symbol:"$"});
           input.attr({"id":"old_" + name, "name":"old_" + name});
           hiddenCurrency.attr({'name': name, 'type': 'hidden'}).appendTo(form);

           form.submit(function(){
             hiddenCurrency.val(Math.round( parseFloat(input.val().substr(1).replace(/,/,"")) * 100 ));
           });
          });
        }
      };
    }
    return modelCache.donation;
  };

  return {
    chart: chart,
    section: section,
    performance: performance,
    artfully_event: artfully_event,
    donation: donation
  };
}());