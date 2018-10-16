# frozen_string_literal: true

require_relative './field_comparison'

class MembershipComparison
  class StartComparison < FieldComparison
    self.field = :start

    def conflict?
      term_started_during_statement? &&
        (term_open? || term_ended_after_statement?)
    end

    def partial?
      term_started_during_statement? ||
        (term_open? && term_started_after_statement?)
    end

    private

    def term_started_during_statement?
      return false unless statement_closed? && term_started?

      statement_start <= term_start && term_start < statement_end
    end

    def term_ended_after_statement?
      return false unless statement_closed? && term_closed?

      statement_end < term_end
    end

    def term_started_after_statement?
      return false unless statement_started? && term_started?

      statement_start <= term_start
    end

    def statement_started?
      statement_start
    end

    def statement_closed?
      statement_started? && statement_end
    end

    def statement_open?
      !statement_closed?
    end

    def term_started?
      term_start
    end

    def term_closed?
      term_started? && term_end
    end

    def term_open?
      !term_closed?
    end

    def statement_start
      statement[:start]
    end

    def statement_end
      statement[:end]
    end

    def term_start
      suggestion.dig(:term, :start)
    end

    def term_end
      suggestion.dig(:term, :end)
    end
  end
end
