module MessageCustomize
  module Locale

    class << self
      def available_locales
        @locales ||= I18n.load_path.map {|path| File.basename(path, '.*')}.uniq.sort.map(&:to_sym)
      end

      def reload!(*languages)
        available_languages = self.find_language(languages.flatten)
        paths = I18n.load_path.select {|path| available_languages.include?(File.basename(path, '.*').to_s)}
        I18n.backend.load_translations(paths)
      end

      def find_language(language=nil)
        return nil if language.nil?

        if language.is_a?(Array)
          language.select{|l| self.find_language(l).present?}.map(&:to_s).uniq
        elsif language.present? && self.available_locales.include?(:"#{language}")
          language.to_s
        end
      end
    end
  end
end