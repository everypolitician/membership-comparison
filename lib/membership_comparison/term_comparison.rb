# frozen_string_literal: true

require_relative './field_comparison'
require_relative './date_helpers'

class MembershipComparison
  class TermComparison < FieldComparison
    include DateHelpers

    self.field = :term

    def conflict
      if spanning_terms?
        'spanning terms'
      elsif previous_term_still_open?
        'previous term still open'
      end
    end

    private

    def _conflict?
      spanning_terms? || previous_term_still_open?
    end

    def _partial?
      !(ended_before_end_of_previous_term? || suggestion_started_after_statement_ended?) &&
        (no_term_or_statement_start? || term_started_during_statement? || term_started_after_statement?)
    end

    def spanning_terms?
      !suggestion_started_after_statement_ended? &&
        term_started_during_statement? &&
        (term_open? || term_ended_after_statement?)
    end

    def previous_term_still_open?
      !suggestion_started_after_statement_ended? &&
        suggestion_started_after_statement_and_term?
    end
  end
end
