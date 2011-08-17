class EditableShortText < EditableElement

  ## fields ##
  localized_field :content

  ## methods ##

  # def content
  #   self.read_attribute(:content).blank? ? self.default_content : self.read_attribute(:content)
  # end

  def content_with_localization
    value = self.content_without_localization
    value.blank? ? self.default_content : value
  end

  alias_method_chain :content, :localization

end