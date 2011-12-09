var LolitaI18nCell, LolitaTranslate, params;
LolitaI18nCell = (function() {
  function LolitaI18nCell(td) {
    this.td = td;
    this.p = this.td.find('p:first');
  }
  LolitaI18nCell.prototype.edit = function() {
    var input, that;
    if (this.td.find('input').size() === 0) {
      this.key = this.td.attr('data-key');
      this.locale = this.td.attr('data-locale');
      input = $('<textarea name="' + this.key + '" />').html(this.fix_quotes(this.p.text().trim()));
      input.css('width', this.p.width() + 'px').css('height', this.p.height() + 'px');
      this.p.html("");
      this.p.hide();
      this.td.append(input);
      input.focus();
      that = this;
      input.blur(function() {
        that.value = input.val().trim();
        input.remove();
        that.add_spinner();
        return that.save();
      });
      return input.keyup(function(e) {
        if (e.keyCode === 27) {
          return input.trigger('blur');
        }
      });
    }
  };
  LolitaI18nCell.prototype.save = function() {
    var that;
    that = this;
    return $.ajax({
      type: 'PUT',
      url: '/lolita/i18n/' + this.locale + '.' + that.key,
      data: {
        translation: that.value
      },
      dataType: 'json',
      success: function(data) {
        if (data.error) {
          alert("Error saving translation " + that.key);
        }
        return that.remove_spinner();
      }
    });
  };
  LolitaI18nCell.prototype.add_spinner = function() {
    var opts;
    opts = {
      lines: 10,
      length: 3,
      width: 2,
      radius: 5,
      color: '#000',
      speed: 1,
      trail: 20,
      shadow: false
    };
    this.spinner = Spinner(opts).spin();
    this.td.prepend(this.spinner.el);
    return $(this.spinner.el).css('top', ($(this.spinner.el).parent().height() / 2) + 'px').css('left', '5px').css('clear', 'both');
  };
  LolitaI18nCell.prototype.remove_spinner = function() {
    this.spinner.stop();
    this.p.text(this.value);
    return this.p.show();
  };
  LolitaI18nCell.prototype.fix_quotes = function(value) {
    return value.replace(/\'/g, "&#39;").replace(/\"/g, "&#34;");
  };
  return LolitaI18nCell;
})();
LolitaTranslate = (function() {
  function LolitaTranslate(button) {
    this.button = button;
    this.url = this.button.attr('data-url');
    this.locale = this.button.attr('data-locale');
    this.add_spinner();
    this.translate();
  }
  LolitaTranslate.prototype.translate = function() {
    var that;
    that = this;
    return $.ajax({
      type: 'PUT',
      url: this.url,
      data: {
        active_locale: this.locale
      },
      dataType: 'json',
      success: function(data) {
        if (data.errors.length > 0) {
          alert("Errors\n\n" + data.errors.join("\n"));
          that.remove_spinner();
        }
        if (data.translated > 0) {
          return window.location.reload();
        } else {
          return that.remove_spinner();
        }
      },
      error: function(request, error) {
        alert("Error 500");
        return that.remove_spinner();
      }
    });
  };
  LolitaTranslate.prototype.add_spinner = function() {
    var opts;
    opts = {
      lines: 10,
      length: 3,
      width: 2,
      radius: 5,
      color: '#000',
      speed: 1,
      trail: 5,
      shadow: false
    };
    this.spinner = Spinner(opts).spin();
    this.button.append(this.spinner.el);
    this.button.addClass('loading');
    this.button.attr('disabled', true);
    return $(this.spinner.el).css('position', 'absolute').css('top', '17px').css('left', '16px');
  };
  LolitaTranslate.prototype.remove_spinner = function() {
    this.spinner.stop();
    this.button.removeClass('loading');
    return this.button.attr('disabled', false);
  };
  return LolitaTranslate;
})();
params = function(name) {
  return decodeURI((RegExp(name + '=' + '(.+?)(&|$)').exec(location.search) || [1, null])[1]);
};
$(function() {
  $('.list td p').click(function() {
    var cell;
    cell = new LolitaI18nCell($(this).parent());
    return cell.edit();
  });
  $('.list td span.hint').click(function() {
    var cell;
    cell = new LolitaI18nCell($(this).parent());
    return cell.edit();
  });
  $('#active_locale').change(function() {
    var show_untranslated;
    show_untranslated = params('show_untranslated') === "null" ? "" : "&show_untranslated=true";
    return window.location.href = "?active_locale=" + $(this).val() + show_untranslated;
  });
  $('button.translate:first').click(function() {
    if (confirm('Are you shure?')) {
      return new LolitaTranslate($(this));
    }
  });
  return $('#show_untranslated').change(function() {
    var active_locale;
    active_locale = params('active_locale') === "null" ? "" : "active_locale=" + params('active_locale');
    if ($(this).attr('checked')) {
      return window.location.href = "?show_untranslated=true&" + active_locale;
    } else {
      return window.location.href = "?" + active_locale;
    }
  });
});