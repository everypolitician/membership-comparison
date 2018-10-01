# frozen_string_literal: true

require_relative './statement_comparison'

module Wikidata
  class MembershipComparison
    def initialize(existing:, suggestion:)
      @existing = existing
      @suggestion = suggestion
    end

    def exact_matches
      classified.fetch(:exact, [])
    end

    def partial_matches
      classified.fetch(:partial, [])
    end

    def conflicts
      classified.fetch(:conflict, [])
    end

    private

    attr_reader :existing, :suggestion

    def classified
      @classified ||= existing.each_with_object({}) do |(id, statement), h|
        comparison = StatementComparison.new(statement:  statement,
                                             suggestion: suggestion)
        state = comparison.state
        next unless state

        h[state] ||= []
        h[state] << id
      end
    end
  end
end
