module Locomotive
  module Liquid
    module Tags
      # Display the links to change the locale of the current page
      #
      # Usage:
      #
      # {% locale_switcher %} => <div id="locale-switcher"><a href="/features" class="current en">Features</a><a href="/fr/fonctionnalites" class="fr">Fonctionnalités</a></div>
      #
      # {% locale_switcher label: locale, sep: ' - ' }
      #
      # options:
      #   - label: iso (de, fr, en, ...etc), locale (Deutsch, Français, English, ...etc), title (page title)
      #   - sep: piece of html code seperating 2 locales
      #
      # notes:
      #   - "iso" is the default choice for label
      #   - " | " is the default seperating code
      #
      class LocaleSwitcher < ::Liquid::Tag

        Syntax = /(#{::Liquid::Expression}+)?/

        def initialize(tag_name, markup, tokens, context)
          @options = { :label => 'iso', :sep => ' | ' }

          if markup =~ Syntax
            markup.scan(::Liquid::TagAttributes) { |key, value| @options[key.to_sym] = value.gsub(/"|'/, '') }

            @options[:exclude] = Regexp.new(@options[:exclude]) if @options[:exclude]
          else
            raise ::Liquid::SyntaxError.new("Syntax Error in 'locale_switcher' - Valid syntax: locale_switcher <options>")
          end

          super
        end

        def render(context)
          site = context.registers[:site]
          current_page = context.registers[:page]

          output = %(<div id="locale-switcher">)

          output += site.locales.collect do |locale|
            I18n.with_site_locale(locale) do
              url = current_page.fullpath_with_locale(locale)

              if current_page.templatized?
                url.gsub!('content_type_template', context['content_instance']._permalink)
              end

              %(<a href="/#{url}" class="#{locale} #{'current' if locale == context['current_locale']}">#{link_label(current_page)}</a>)
            end
          end.join(@options[:sep])

          output += %(</div>)
        end

        private

        def link_label(current_page)
          case @options[:label]
          when :iso     then I18n.site_locale
          when :locale  then I18n.t("admin.locales.#{I18n.site_locale}", :locale => I18n.site_locale)
          when :title   then current_page.title
          else
            I18n.site_locale
          end
        end

      end

      ::Liquid::Template.register_tag('locale_switcher', LocaleSwitcher)
    end
  end
end
