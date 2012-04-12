$(function(){
  $("textarea").focus(function(){
    $(this).data("original-text",$(this).val())
  })

  $("textarea").blur(function(){
    if($(this).data("original-text")!=$(this).val()){
      $(this).data("original-text",false)
      var $td = $(this).parents("td:eq(0)")
      var key = $td.data("key")
      var locale = $td.data("locale")
      var $textareas = $("td[data-key='"+key+"'] textarea");
      var result_arr = []
      var result_json = {}

      $textareas.each(function(index){
        var current_key = locale + "." + $(this).attr("name")
        var m_data = current_key.match(/\[(\d+)\]$/)
        if(m_data){
          result_arr[parseInt(m_data[m_data.length-1])] = $(this).val()
        }else{
          keys = current_key.split(".")
          json_key = keys[keys.length-1]
          result_json[json_key] = $(this).val()
        }
      })

      that = this
      new_id = Base64.encode(key)
      $.ajax({
        type: 'PUT',
        url: '/lolita/i18n/' + new_id,
        data: {translation: result_arr.length == 0 ? result_json : result_arr},
        dataType: 'json',
        success: function(data){
          if(data.error){
            alert("Error saving translation:\n\n" + data.error)
          }
          //that.remove_spinner()
        },
        error: function(request){}
          //that.remove_spinner()
      })
    }

  })
})