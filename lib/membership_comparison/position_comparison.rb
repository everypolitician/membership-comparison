# frozen_string_literal: true

require_relative './statement_comparison'

class MembershipComparison
  class PositionComparison
    def initialize(statement:, suggestion:, options:)
      @statement = statement
      @suggestion = suggestion
      @options = options
    end

    def state
      return unless position_match? || superclass_match?
      return :ignore if bare?
      return :conflict if conflicted?

      statement_comparison.state
    end

    def conflicts
      return [] unless position_match? || superclass_match?
      return ['position conflict'] if conflicted? && !bare?

      statement_comparison.conflicts
    end

    def field_states
      return {} unless position_match? || superclass_match?

      statement_comparison.field_states.tap do |states|
        states[:position] = state if superclass_match?
      end
    end

    private

    attr_reader :statement, :suggestion, :options

    def position_match?
      statement[:position] == suggestion[:position]
    end

    def superclass_match?
      statement[:position] == suggestion[:position_parent]
    end

    def bare?
      superclass_match? && statement.reject { |k| k == :position }.values.all?(&:empty?)
    end

    def conflicted?
      # Exact and Partial states should be considered as conflicts when we're
      # comparing superclass positions as we don't support updating these.

      superclass_match? && %i[exact partial].include?(statement_comparison.state)
    end

    def statement_comparison
      @statement_comparison ||= StatementComparison.new(
        statement:  statement,
        suggestion: suggestion,
        options:    options
      )
    end
  end
end
