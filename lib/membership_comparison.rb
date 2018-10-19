# frozen_string_literal: true

require_relative './membership_comparison/statement_comparison'

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

  def problems
    comparisons.each_with_object({}) do |(id, comparison), memo|
      memo[id] = comparison.conflicts
    end
  end

  private

  attr_reader :existing, :suggestion

  def classified
    @classified ||= comparisons.each_with_object({}) do |(id, comparison), memo|
      state = comparison.state
      next unless state

      memo[state] ||= []
      memo[state] << id
    end
  end

  def comparisons
    @comparisons ||= existing.each_with_object({}) do |(id, statement), memo|
      memo[id] = StatementComparison.new(
        statement:  statement,
        suggestion: suggestion,
        options:    options
      )
    end
  end

  def options
    {
    }
  end
end
