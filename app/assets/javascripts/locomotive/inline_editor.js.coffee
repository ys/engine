#= require jquery
#= require jquery-ui
#= require jquery_ujs
#= require underscore
#= require backbone
#= require locomotive/backbone.sync
#= require locomotive/backbone.modelbinding
#= require codemirror
#= require tinymce-jquery
#= require codemirror/utils/overlay
#= require codemirror/modes/css
#= require codemirror/modes/javascript
#= require codemirror/modes/xml
#= require codemirror/modes/htmlmixed
#= require locomotive/growl
#= require locomotive/handlebars
#= require locomotive/ICanHandlebarz
#= require locomotive/resize
#= require locomotive/cmd
#= require locomotive/form_submit_notification
#= require locomotive/slugify
#= require locomotive/toggle
#= require_self
#= require_tree ./utils
#= require_tree ./models
#= require_tree ./views/content_assets
#= require_tree ./views/shared
#= require_tree ./views/content_entries
#= require_tree ./views/content_types
#= require_tree ./views/inline_editor

window.Locomotive =
  mounted_on:   window.Locomotive.mounted_on
  Models:       {}
  Collections:  {}
  Views:        {}
