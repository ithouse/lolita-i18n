class LolitaI18nCell

  constructor: (@td) ->
    @p = @td.find('p:first')
   
  edit: ->
    if @td.find('input').size() == 0
      @key     = @td.attr('data-key')
      @locale  = @td.attr('data-locale')
      input    = $('<textarea name="'+@key+'" />').html(@fix_quotes(@p.text().trim()))
      input.css('width',@p.width+'px')
      @p.html("")
      @td.append(input)
      input.focus()
      that = this

      input.blur ->
        that.value = input.val().trim()
        input.remove()
        that.add_spinner()
        that.save()

      input.keyup (e) ->
        if e.keyCode == 27
          input.trigger('blur')
  
  save: ->
    that = this
    $.ajax 
      type: 'PUT'
      url: '/lolita/i18n/' + @locale + '.' + that.key
      data: {translation: that.value}
      dataType: 'json'
      success: (data) ->
        if data.error
          alert "Error saving translation " + that.key
        that.remove_spinner()

  add_spinner: ->
    opts =
      lines: 10
      length: 3
      width: 2
      radius: 5,
      color: '#000'
      speed: 1
      trail: 20
      shadow: false

    @spinner = Spinner(opts).spin()
    @td.prepend(@spinner.el)
    $(@spinner.el).css('top',($(@spinner.el).parent().height() / 2)+ 'px').css('left','5px').css('clear','both')

  remove_spinner: ->
    @spinner.stop()
    @p.html(@value)

  fix_quotes: (value) ->
    value.replace(/\'/g, "&#39;").replace(/\"/g, "&#34;")

$ ->
  $('.list td p').click ->
    cell = new LolitaI18nCell $(this).parent()
    cell.edit()
  $('.list td span.hint').click ->
    cell = new LolitaI18nCell $(this).parent()
    cell.edit()
  $('#active_locale').change ->
    window.location.href = "?active_locale=" + $(this).val()