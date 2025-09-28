# frozen_string_literal: true

module Challenge
  module Formatters
    # Formats output as well-formed XML with proper escaping
    class XMLFormatter
      def format_search_results(results, query)
        lines = ['<?xml version="1.0" encoding="UTF-8"?>']
        lines << "<search_results query=\"#{escape_xml(query)}\" count=\"#{results.size}\">"
        results.each { |client| lines << format_client_xml(client, '  ') }
        lines << '</search_results>'
        lines.join("\n")
      end

      def format_duplicate_results(duplicates)
        lines = ['<?xml version="1.0" encoding="UTF-8"?>']
        if duplicates.empty?
          lines << '<duplicate_results count="0"/>'
        else
          email_groups = duplicates.group_by { |client| client['email'] }
          lines << "<duplicate_results count=\"#{duplicates.size}\">"
          email_groups.each do |email, clients|
            lines << "  <duplicate_group email=\"#{escape_xml(email)}\">"
            clients.each { |client| lines << format_client_xml(client, '    ') }
            lines << '  </duplicate_group>'
          end
          lines << '</duplicate_results>'
        end
        lines.join("\n")
      end

      def format_generation_result(filename, size)
        [
          '<?xml version="1.0" encoding="UTF-8"?>',
          '<generation_result>',
          '  <status>success</status>',
          '  <message>Dataset generated successfully</message>',
          "  <filename>#{escape_xml(filename)}</filename>",
          "  <size>#{size}</size>",
          '</generation_result>'
        ].join("\n")
      end

      def format_version(version)
        [
          '<?xml version="1.0" encoding="UTF-8"?>',
          '<version>',
          '  <application>challenge</application>',
          "  <number>#{escape_xml(version)}</number>",
          '</version>'
        ].join("\n")
      end

      private

      def format_client_xml(client, indent = '')
        [
          "#{indent}<client id=\"#{client['id']}\">",
          "#{indent}  <full_name>#{escape_xml(client['full_name'])}</full_name>",
          "#{indent}  <email>#{escape_xml(client['email'])}</email>",
          "#{indent}</client>"
        ].join("\n")
      end

      def escape_xml(text)
        return '' if text.nil?

        text.to_s
            .gsub('&', '&amp;')
            .gsub('<', '&lt;')
            .gsub('>', '&gt;')
            .gsub('"', '&quot;')
            .gsub("'", '&apos;')
      end
    end
  end
end
