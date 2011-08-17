module Extensions
  module Shared
    module Seo
      extend ActiveSupport::Concern

      included do
        localized_field :seo_title
        localized_field :meta_keywords
        localized_field :meta_description
      end

    end # Seo
  end # Shared
end # Extensions
