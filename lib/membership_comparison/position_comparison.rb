# frozen_string_literal: true

require_relative './statement_comparison'

class MembershipComparison
  class PositionComparison < StatementComparison
    alias statement_state state

    def state
      return unless position_match? || superclass_match? || subclass_match?
      return :ignore if bare?
      return :conflict if conflicted?

      super
    end

    def conflicts
      return [] unless position_match? || superclass_match? || subclass_match?
      return ['position conflict'] if conflicted? && !bare?

      super
    end

    def field_states
      return {} unless position_match? || superclass_match? || subclass_match?

      super.tap do |states|
        states[:position] = state if superclass_match? || subclass_match?
      end
    end

    private

    def position_match?
      statement[:position] == suggestion[:position]
    end

    def superclass_match?
      statement[:position] == suggestion[:position_parent]
    end

    def subclass_match?
      suggestion[:position_children]&.include?(statement[:position])
    end

    def bare?
      (superclass_match? || subclass_match?) && statement.reject { |k| k == :position }.values.all?(&:empty?)
    end

    def conflicted?
      # Exact and Partial states should be considered as conflicts when we're
      # comparing superclass positions as we don't support updating these.

      (superclass_match? || subclass_match?) && %i[exact partial].include?(statement_state)
    end
  end
end
