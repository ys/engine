class EditableFile < EditableElement

  localized_fields :source_filename

  mount_uploader :source, EditableFileUploader

  # localized_field :source

  def content
    self.source? ? self.source.url : self.default_content
  end

end