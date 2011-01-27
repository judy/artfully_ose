function Chart(data) { this.load(data); }

Chart.prototype = {
  load: function(data){
    this.id = data.id;
    this.name = data.name;
    this.load_sections([], data.sections);
  },

  load_sections: function(collection, sections){
    this.sections = collection;
    if(sections){
      for(var i = 0; i < sections.length; i++){
        this.sections.push(new Section(sections[i]));
      }
    }
  },

  render: function($target){
    if(!this.$view){
      this.$view = this.view();
    }

    this.$view.slideUp('slow',function(){
      $(this).hide().appendTo($target)
      $(this).slideDown('slow');
    });
  },

  view: function(){
    var $view = $(document.createElement('ul')).addClass('sections')

    for(var i = 0; i < this.sections.length; i++){
      this.sections[i].render($view);
    }

    return $view;
  }
};