module Bicho
  module Plugins
    class Aliases
      def transform_site_url_hook(url, _logger)
        case url.to_s
        when 'bko', 'kernel' then 'https://bugzilla.kernel.org'
        when 'bgo', 'gnome' then 'https://bugzilla.gnome.org'
        when 'kde' then 'https://bugzilla.kde.org'
        else url
        end
      end
    end
  end
end
