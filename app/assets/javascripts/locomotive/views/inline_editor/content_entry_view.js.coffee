Locomotive.Views.InlineEditor ||= {}

class Locomotive.Views.InlineEditor.ContentEntryView extends Backbone.View

  tagName: 'li'
  className: 'entry'

  events:
    'click a': 'show_edition_popup'

  render: () ->
    @$el.append ich.content_entry_select(@model.toJSON())
    @

  show_edition_popup: (e) ->
    e.stopPropagation() & e.preventDefault()
    @modal_form_view?.leave()
    @modal_form_view = new Locomotive.Views.InlineEditor.ModalFormView(model: @model)
    @modal_form_view.render().open()
    $('.list-container').hide()
    $('#content-types-select').show()
    Locomotive.current_content_entries_view.leave()

