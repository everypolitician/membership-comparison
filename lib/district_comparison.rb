# frozen_string_literal: true

require_relative './field_comparison'

module Wikidata
  class DistrictComparison < FieldComparison
    self.field = :district
  end
end
