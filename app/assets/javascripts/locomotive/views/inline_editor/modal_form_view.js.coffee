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
      hbs_templates = ($(elm).attr('id') for elm in @$el.find('script[type="text/html"]'))
      @add_new_templates(hbs_templates)
      super()

  save: (event) ->
    @save_in_ajax event,
      headers:  { 'X-Flash': true }
      on_success: (response, xhr) =>
        @add_or_update(response)
        @reload_content_page()
        @close()

  custom_create_actions: ->
    #@$('#local-actions-bottom-bar').remove()
    @$('>p').remove()
    @$('fieldset.foldable').remove()
    actions = @$('#modal-form>form>.dialog-actions').appendTo($(@el).parent()).addClass('ui-dialog-buttonpane ui-widget-content ui-helper-clearfix')
    actions.find('#close-link').click (event) => @close(event)
    actions.find('input[type=submit]').click (event) =>
      # since the submit buttons are outside the form, we have to mimic the behaviour of a basic form
      $form = @$el.find('form'); $buttons_pane = $(event.target).parent()

      $.rails.disableFormElements($buttons_pane)

      $form.trigger('submit').bind 'ajax:complete', => $.rails.enableFormElements($buttons_pane)

  leave: ->
    @off()
    console.log @$el
    @$el.dialog( "destroy" )
    @remove()
    $('body').append('<div id=modal-form></div>')

  after_close_event: (event) ->
    @leave()

  add_new_templates: (templates) ->
    for key in templates
      delete ich[key]
      delete ich.templates[key]
      ich.addTemplate(key, $("##{key}").html())

  add_or_update: (response) ->
    entry = new Locomotive.Models.ContentEntry(response)
    if Locomotive.content_entries.get(entry.id)?
      Locomotive.content_entries.get(entry.id).set(entry.attributes)
    else
      Locomotive.content_entries.add(entry)

  reload_content_page: () ->
    $('#page iframe').attr('src', $('#page iframe').attr('src'))

