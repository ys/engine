Locomotive.Views.InlineEditor ||= {}

class Locomotive.Views.InlineEditor.ModalFormView extends Locomotive.Views.ContentEntries.PopupFormView

  el: '#modal-form'

  initialize: () ->
    Locomotive.new_model = @model
    url = "/admin/content_types/#{@model.get('content_type_slug')}/entries/new"
    url = "#{ @model.url() }/edit" unless @model.isNew()

    request = $.ajax
      url: url
      async: false

    request.success (data) =>
      @$el.html ich.content_entry_form({title: @model.get('content_type_slug'), data: data})

      @add_new_templates()
      @options[key] = value for key, value of application_view.view_data
      super()

  save: (event) ->
    @save_in_ajax event,
      headers:  { 'X-Flash': true }
      on_success: (response, xhr) =>
        @add_or_update(response)
        @reload_content_page()
        @reload_content_entries()
        @close()

  custom_create_actions: ->
    @$('#local-actions-bottom-bar').remove()
    @$('>p').remove()
    @$('fieldset.foldable').remove()
    actions = @$('>.dialog-actions').appendTo($(@el).parent()).addClass('ui-dialog-buttonpane ui-widget-content ui-helper-clearfix')
    actions.find('#close-link').click (event) => @close(event)
    actions.find('input[type=submit]').click (event) =>
      # since the submit buttons are outside the form, we have to mimic the behaviour of a basic form
      $form = @$el.find('form'); $buttons_pane = $(event.target).parent()
      $.rails.disableFormElements($buttons_pane)
      $form.trigger('submit').bind 'ajax:complete', => $.rails.enableFormElements($buttons_pane)

  leave: ->
    @off()
    @$el.dialog( "destroy" )
    @remove()
    $('body').append('<div id=modal-form></div>')

  after_close_event: (event) ->
    @leave()

  add_new_templates: () ->
    templates = ($(elm).attr('id') for elm in @$el.find('script[type="text/html"]'))
    trash = []
    for key in templates
      delete ich[key]
      delete ich.templates[key]
      ich.addTemplate(key, $("##{key}").html())
      trash.unshift($("##{key}"));
    t.remove() for t in trash

  add_or_update: (response) ->
    entry = new Locomotive.Models.ContentEntry(response)
    Locomotive.content_entries.add_or_update([entry])

  reload_content_page: () ->
    $('#page iframe').attr('src', window.location.pathname.replace('_admin', '_edit'))

  reload_content_entries: () ->
    for content_type in Locomotive.content_types.models
      content_entries = content_type.fetchEntries
        success: (collection, response) ->
          Locomotive.content_entries.add_or_update collection.models

