# frozen_string_literal: true

require_relative './field_comparison'

class MembershipComparison
  class StartComparison < FieldComparison
    self.field = :start

    def conflict?
      !suggestion_started_after_statement_ended? && ((
        term_started_during_statement? &&
        (statement_open? || term_open? || term_ended_after_statement?)
      ) || suggestion_started_after_statement_and_term?)
    end

    def partial?
      !suggestion_started_after_statement_ended? && (
        term_started_during_statement? ||
        (statement_open? && term_open? && term_started_after_statement?)
      )
    end

    private

    def suggestion_started_after_statement_ended?
      return false unless statement_closed? && suggestion_started?

      statement_end < suggestion_start
    end

    def suggestion_started_after_statement_and_term?
      return false unless term_started? && suggestion_started? && statement_open?

      statement_start <= term_start && term_start < suggestion_start
    end

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

    def suggestion_started?
      suggestion_start
    end

    def suggestion_closed?
      suggestion_started? && suggestion_end
    end

    def suggestion_open?
      !suggestion_closed?
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

    def suggestion_start
      suggestion[:start]
    end

    def suggestion_end
      suggestion[:end]
    end
  end
end
