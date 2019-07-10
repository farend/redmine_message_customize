module MessageCustomize
  module Locale

    class << self
      def available_locales
        I18n.load_path.map {|path| File.basename(path, '.*')}.uniq.sort.map(&:to_sym)
      end

      def reload!(languages)
        paths = I18n.load_path.select {|path| self.find_language(languages).include?(File.basename(path, '.*').to_s)}
        I18n.backend.load_translations(paths)
      end

      def find_language(language=nil)
        if language.is_a?(Array)
          language.select{|l| self.available_locales.include?(:"#{l}")}.map(&:to_s).compact
        elsif language.present? && self.available_locales.include?(:"#{language}")
          language.to_s
        end
      end
    end
  end
end