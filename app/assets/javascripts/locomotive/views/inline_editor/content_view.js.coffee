Locomotive.Views.InlineEditor ||= {}

class Locomotive.Views.InlineEditor.ContentView extends Backbone.View

  el: '#content-types'

  events:
    'click  .toggler':              'toggle_list'
    'click  #content-types-select li': 'show_content_entries_for_type'


  initialize: ->

  toggle_list: () ->
    @$('.list-container').toggle()

  show_content_entries_for_type: (e) ->
    e.stopPropagation() & e.preventDefault()
    current_type_slug = $(e.currentTarget).find('a').attr('href')[1..-1]
    content_entries = Locomotive.content_entries.where({'content_type_slug': current_type_slug })
    @current_type = @collection.where({slug:current_type_slug })[0]
    @content_entries_view = new Locomotive.Views.InlineEditor.ContentEntriesView(content_type: @current_type, collection: new Locomotive.Models.ContentEntriesCollection(content_entries))
    @content_entries_view.bind('leave', @show_types, @)
    @$('#content-types-select').hide()
    @$('.list-container').append(@content_entries_view.render().el)

  show_types: ->
    @$('#content-types-select').show()

