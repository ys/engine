Locomotive.Views.InlineEditor ||= {}

class Locomotive.Views.InlineEditor.ModalFormView extends Locomotive.Views.ContentEntries.PopupFormView

  el: '#modal-form'

  initialize: () ->
    Locomotive.new_model = @model
    url = "/admin/content_types/#{@model.get('content_type_slug')}/entries/new"
    url = "#{ @model.url() }/edit" unless @model.isNew()
          #"/admin/content_types/#{@model.get('content_type_slug')}/entries/#{@model.id}/edit"

    request = $.ajax
      url: url
      async: false

    request.success (data) =>
      @$el.html ich.content_entry_form({title: @model.get('content_type_slug'), data: data})
      @add_new_templates()
      super()

  custom_create_actions: ->
    @$('#local-actions-bottom-bar').remove()
    @$('>p').remove()
    @$('fieldset.foldable').remove()

  leave: ->
    @off()
    console.log @$el
    @$el.dialog( "destroy" )
    @remove()
    $('body').append('<div id=modal-form></div>')

  after_close_event: (event) ->
    @leave()

  add_new_templates: ->
    for key of ich.templates when /(input|list|entry|button)$/.test(key)
      delete ich[key]
      delete ich.templates[key]
    ich.grabTemplates()


