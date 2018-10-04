# frozen_string_literal: true

require_relative './field_comparison'

module Wikidata
  class PartyComparison < FieldComparison
    self.field = :party
  end
end
