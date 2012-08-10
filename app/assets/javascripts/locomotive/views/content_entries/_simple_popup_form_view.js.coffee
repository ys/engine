#= require ../shared/form_view

Locomotive.Views.ContentEntries ||= {}

class Locomotive.Views.ContentEntries.SimplePopupFormView extends Locomotive.Views.ContentEntries.PopupFormView

  slugify_label_field: ->
    # disabled in a popup form

  enable_has_many_fields: ->
    # disabled in a popup form

  enable_many_to_many_fields: ->
    # disabled in a popup form
  custom_create_actions: ->
    actions = @$('.dialog-actions').appendTo($(@el).parent()).addClass('ui-dialog-buttonpane ui-widget-content ui-helper-clearfix')
    actions.find('#close-link').click (event) => @close(event)
    actions.find('input[type=submit]').click (event) =>
      # since the submit buttons are outside the form, we have to mimic the behaviour of a basic form
      $form = @$el.find('form'); $buttons_pane = $(event.target).parent()
      $.rails.disableFormElements($buttons_pane)
      $form.trigger('submit').bind 'ajax:complete', => $.rails.enableFormElements($buttons_pane)

