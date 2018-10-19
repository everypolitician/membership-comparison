# frozen_string_literal: true

require_relative './party_comparison'
require_relative './district_comparison'
require_relative './term_comparison'
require_relative './start_comparison'

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
      elsif comparisons.any?(&:conflict?)
        :conflict
      elsif comparisons.any?(&:partial?)
        :partial
      end
    end

    def conflicts
      comparisons.map(&:conflict).compact
    end

    private

    attr_reader :statement, :suggestion, :options

    def comparisons
      @comparisons ||= [party_comparison, district_comparison, term_comparison, start_comparison]
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

    def start_comparison
      StartComparison.new(statement: statement, suggestion: suggestion, options: options)
    end
  end
end
