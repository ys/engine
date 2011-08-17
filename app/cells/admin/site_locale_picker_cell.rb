class Admin::SiteLocalePickerCell < Cell::Base

  def show(args)
    site    = args[:site]
    locale  = args[:locale].to_s

    if site.locales.empty? || site.locales.size < 2
      ''
    else
      @locales = [locale] + (site.locales - [locale])
      render
    end
  end

end