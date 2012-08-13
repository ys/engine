Locomotive.Views.InlineEditor ||= {}

class Locomotive.Views.InlineEditor.ContentEntriesView extends Backbone.View

  tagName: 'ul'
  id: 'content-entries-select'

  events:
    'click .new': 'show_new_popup_for_content_type'
    'click .back': 'show_content_types'

  initialize: (options) ->
    @content_type = options['content_type']

  render: () ->
    @$el.append ich.content_entries_select()
    for content_entry in @collection.models
      content_entry_view = new Locomotive.Views.InlineEditor.ContentEntryView(model: content_entry, parent: @)
      @$el.append content_entry_view.render().el
    @

  show_content_types: (e) ->
    e.stopPropagation() & e.preventDefault()
    @leave()

  show_new_popup_for_content_type: (e) ->
    e.stopPropagation() & e.preventDefault()
    sample = @collection.models[0]
    model = new Locomotive.Models.ContentEntry
      content_type_slug: @content_type.get('slug')
      safe_attributes: sample?.get('safe_attributes')
      file_custom_fields: sample?.get('file_custom_fields')
      has_many_custom_fields: sample?.get('has_many_custom_fields')
      many_to_many_custom_fields: sample?.get('many_to_many_custom_fields')
      select_custom_fields: sample?.get('select_custom_fields')
    @modal_form_view?.leave()
    @modal_form_view = new Locomotive.Views.InlineEditor.ModalFormView(model: model)
    @modal_form_view.render().open()
    $('.list-container').hide()
    @leave()

  leave: ->
    @trigger('leave')
    @off()
    @remove()
