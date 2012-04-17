$(function(){

  $('#active_locale').change(function(){
    params("active_locale",$(this).val())
  })

  $('#show_untranslated').change(function(){
    params("show_untranslated", $(this).is(':checked') ? "1" : false)
  })

  var resize  = function($textarea) {
    $textarea[0].style.height = 'auto';
    $textarea[0].style.height = ($textarea[0].scrollHeight  + $textarea.data("offset") ) + 'px';  
  }

  var reset_size = function($textarea){
    $textarea[0].style.height = 'auto';
    $textarea[0].style.height = ($textarea.data("offset") ) + 'px'; 
  }

  $("textarea").each(function(){
    var t = $(this)[0]
    var offset= !window.opera ? (t.offsetHeight - t.clientHeight) : (t.offsetHeight + parseInt(window.getComputedStyle(t, null).getPropertyValue('border-top-width'))) ;
    $(this).data("offset",offset)
  })

  $("textarea").keyup(function(){
    resize($(this))
  })

  $("textarea").focus(function(){
    resize($(this))
    $(this).data("original-text",$(this).val())
  })

  $("textarea").blur(function(){
    if($(this).data("original-text")!=$(this).val()){
      $(this).data("original-text",false)
      var $td = $(this).parents("td:eq(0)")
      var key = $td.data("key")
      var locale = $td.data("locale")
      var $textareas = $("td[data-key='"+key+"'] textarea");
      var result_str = ""
      var result_arr = false
      var result_json = false

      if($textareas.length > 1){
        $textareas.each(function(index){
          var current_key = locale + "." + $(this).attr("name")
          var m_data = current_key.match(/\[(\d+)\]$/)
          if(m_data){
            result_arr = result_arr || []
            result_arr[parseInt(m_data[m_data.length-1])] = $(this).val()
          }else{
            result_json = result_json || {}
            keys = current_key.split(".")
            json_key = keys[keys.length-1]
            result_json[json_key] = $(this).val()
          }
        })
      }else{
        result_str = $textareas.eq(0).val()
      }
      
      new_id = Base64.encode(key)
      save(result_arr || result_json || result_str, new_id)
    }
    reset_size($(this))
  })

  var save = function(post_data,id){
    $.ajax({
      type: 'PUT',
      url: '/lolita/i18n/' + id,
      data: {translation: post_data},
      dataType: 'json',
      success: function(data){
        if(data.error){
          show_error_msg( data.error)
        }
      },
      error: function(request){
        show_error_msg("Connection error! Translation is not saved!")
      }
    })
  }
})