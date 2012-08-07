Locomotive.Views.InlineEditor ||= {}

class Locomotive.Views.InlineEditor.ContentEntriesView extends Backbone.View

  tagName: 'ul'
  id: 'content-entries-select'
  className: 'list'

  events:
    'click .new': 'show_new_popup_for_content_type'

  initialize: (options) ->
    @content_type = options['content_type']

  render: () ->
    console.log @collection
    @$el.append ich.content_entries_select()
    for content_entry in @collection.models
      content_entry_view = new Locomotive.Views.InlineEditor.ContentEntryView(model: content_entry)
      console.log content_entry
      @$el.append content_entry_view.render().el #ich.content_entry_select(con.toJSON())
    @

  show_new_popup_for_content_type: (e) ->
    e.stopPropagation() & e.preventDefault()
    console.log 'NEW POPUP'
    request = $.get "/admin/content_types/#{@content_type.get('slug')}/entries/new"
    request.success (data) ->
      console.log data

  leave: ->
    @off()
    @remove()
