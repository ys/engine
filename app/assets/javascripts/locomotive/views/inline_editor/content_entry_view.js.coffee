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
    console.log 'EDITION POPUP'

