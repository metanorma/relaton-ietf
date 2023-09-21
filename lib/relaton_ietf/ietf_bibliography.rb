# frozen_string_literal:true

require "relaton_ietf/scrapper"

module RelatonIetf
  # IETF bibliography module
  module IetfBibliography
    class << self
      # @param code [String] the ISO standard Code to look up (e..g "ISO 9000")
      # @return [RelatonIetf::IetfBibliographicItem]
      def search(text)
        Scrapper.scrape_page text
      end

      # @param code [String] the ISO standard Code to look up (e..g "ISO 9000")
      # @param year [String] the year the standard was published (optional)
      # @param opts [Hash] options; restricted to :all_parts if all-parts
      #   reference is required
      # @return [RelatonIetf::IetfBibliographicItem] Relaton of reference
      def get(code, _year = nil, _opts = {})
        Util.warn "(#{code}) fetching..."
        result = search code
        if result
          docid = result.docidentifier.detect(&:primary) || result.docidentifier.first
          Util.warn "(#{code}) found `#{docid.id}`"
        else
          Util.warn "(#{code}) not found"
        end
        result
      end
    end
  end
end
