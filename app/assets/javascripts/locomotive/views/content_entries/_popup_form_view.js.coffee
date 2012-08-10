#= require ../shared/form_view

Locomotive.Views.ContentEntries ||= {}

class Locomotive.Views.ContentEntries.PopupFormView extends Locomotive.Views.ContentEntries.FormView

  initialize: ->
    @create_dialog()

    super()

  render: ->
    super()

    return @

  save: (event) ->
    @save_in_ajax event,
      headers:  { 'X-Flash': true }
      on_success: (response, xhr) =>
        entry = new Locomotive.Models.ContentEntry(response)
        @options.parent_view.insert_or_update_entry(entry)
        @close()

  create_dialog: ->
    @dialog = $(@el).dialog
      autoOpen: false
      modal:    true
      zIndex:   window.application_view.unique_dialog_zindex()
      width:    770,
      create: (event, ui) =>
        $(@el).prev().find('.ui-dialog-title').html(@$('h2').html())
        @$('h2').remove()
        @custom_create_actions()

      open: (event, ui, extra) =>
        $(@el).dialog('overlayEl').bind 'click', => @close()
        # nothing to do

  open: ->
    console.log 'OPEN'
    parent_el = $(@el).parent()
    if @model.isNew()
      parent_el.find('.edit-section').hide()
      parent_el.find('.new-section').show()
    else
      parent_el.find('.new-section').hide()
      parent_el.find('.edit-section').show()

    @clear_errors()

    $(@el).dialog('open')

  close: (event) ->
    event.stopPropagation() & event.preventDefault() if event?
    @clear_errors()
    $(@el).dialog('overlayEl').unbind('click')
    $(@el).dialog('close')
    @after_close_event(event)

  center: ->
    $(@el).dialog('option', 'position', 'center')

  reset: (entry) =>
    @model.set entry.attributes

    if entry.isNew()
      @model.id = null
      super()
    else
      @refresh()

  tinyMCE_settings: ->
    window.Locomotive.tinyMCE.popupSettings

  custom_create_actions: ->
    #customize in subclasses

  after_close_event: (event) ->
    #customize in subclasses
