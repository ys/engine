module Locomotive
  class ContentTypesSelectCell < Cell::Base

    def show(args)
      content_types = args[:content_types]

      if content_types.empty?
        ''
      else
        @content_types = content_types
        render
      end
    end

  end
end

