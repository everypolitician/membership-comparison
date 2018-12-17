# frozen_string_literal: true

require_relative './person_comparison'
require_relative './party_comparison'
require_relative './district_comparison'
require_relative './term_comparison'

class MembershipComparison
  class StatementComparison
    def initialize(statement:, suggestion:, options:)
      @statement = statement
      @suggestion = suggestion
      @options = options
    end

    def state
      return unless statement[:position] == suggestion[:position]

      if comparisons.all?(&:exact?)
        :exact
      elsif comparisons.any?(&:ignore?)
        :ignore
      elsif comparisons.any?(&:conflict?)
        :conflict
      elsif comparisons.any?(&:partial?)
        :partial
      end
    end

    def conflicts
      return [] unless state == :conflict

      comparisons.map(&:conflict).compact
    end

    def field_states
      comparisons.each_with_object({}) do |comparison, memo|
        memo[comparison.class.field] = comparison.state
      end
    end

    private

    attr_reader :statement, :suggestion, :options

    def comparisons
      @comparisons ||= [person_comparison, party_comparison, district_comparison, term_comparison]
    end

    def person_comparison
      PersonComparison.new(statement: statement, suggestion: suggestion, options: options)
    end

    def party_comparison
      PartyComparison.new(statement: statement, suggestion: suggestion, options: options)
    end

    def district_comparison
      DistrictComparison.new(statement: statement, suggestion: suggestion, options: options)
    end

    def term_comparison
      TermComparison.new(statement: statement, suggestion: suggestion, options: options)
    end
  end
end
