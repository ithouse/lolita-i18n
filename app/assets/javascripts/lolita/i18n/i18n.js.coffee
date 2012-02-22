class LolitaI18nCell

  constructor: (@td) ->
    @p = @td.find('p:first')
   
  edit: ->
    if @td.find('input').size() == 0
      @key     = @td.attr('data-key')
      @locale  = @td.attr('data-locale')
      input    = $('<textarea name="'+@key+'" />').html(@fix_quotes(@p.text().trim()))
      input.css('width',@p.width()+'px').css('height', @p.height()+'px')
      @p.html("")
      @p.hide()
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
    @p.text(@value)
    @p.show()

  fix_quotes: (value) ->
    value.replace(/\'/g, "&#39;").replace(/\"/g, "&#34;")

class LolitaTranslate

  constructor: (@button)->
    @url = @button.attr('data-url')
    @locale = @button.attr('data-locale')
    @add_spinner()
    @translate()

  translate: ->
    that = this

    $.ajax 
      type: 'PUT'
      url: @url
      data: {active_locale: @locale}
      dataType: 'json'
      success: (data) ->
        if data.errors.length > 0
          alert("Errors\n\n" + data.errors.join("\n"))
          that.remove_spinner()
        if data.translated > 0
          window.location.reload()
        else
          that.remove_spinner()
      error: (request,error) ->
        alert "Error 500"
        that.remove_spinner()        

  add_spinner: ->
    opts =
      lines: 10
      length: 3
      width: 2
      radius: 5
      color: '#000'
      speed: 1
      trail: 5
      shadow: false

    @spinner = Spinner(opts).spin()
    @button.append(@spinner.el)
    @button.addClass('loading')
    @button.attr('disabled',true)
    $(@spinner.el).css('position', 'absolute').css('top','17px').css('left','16px')

  remove_spinner: ->
    @spinner.stop()
    @button.removeClass('loading')
    @button.attr('disabled',false)

params = (name) ->
  decodeURI((RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)||[1,null])[1])

$ ->
  $('.list td p').click ->
    cell = new LolitaI18nCell $(this).parent()
    cell.edit()
  $('.list td span.hint').click ->
    cell = new LolitaI18nCell $(this).parent()
    cell.edit()
  $('#active_locale').change ->
    show_untranslated = if params('show_untranslated') == "null" then "" else  "&show_untranslated=true"
    window.location.href = "?active_locale=" + $(this).val() + show_untranslated
  $('button.translate:first').click ->
    if confirm('Are you shure?')
      new LolitaTranslate $(this)
  $('#show_untranslated').change ->
    active_locale = if params('active_locale') == "null" then "" else  "active_locale=" + params('active_locale')
    if $(this).is(':checked')
      window.location.href = "?show_untranslated=true&" + active_locale
    else
      window.location.href = "?" + active_locale
        