# frozen_string_literal: true

RSpec.shared_context 'spec setup', shared_context: :metadata do
  let(:existing) { raise NotImplementedError }
  let(:suggestion) { raise NotImplementedError }

  def comparison
    @comparison ||= begin
      existing_as_hash = existing.each_with_object({}).with_index do |(statement, memo), idx|
        memo[idx] = statement
      end
      MembershipComparison.new(existing: existing_as_hash, suggestion: suggestion)
    end
  end

  let(:exact_matches) { comparison.exact_matches }
  let(:partial_matches) { comparison.partial_matches }
  let(:conflicts) { comparison.conflicts }
  let(:problems) { comparison.problems }

  matcher :be_actionable do
    match do |actual|
      comparison.send(:suggestion) == actual &&
        exact_matches.empty? && conflicts.empty? && problems.values.all?(&:empty?)
    end
  end

  matcher :be_ignored do
    match do |actual|
      key = comparison.send(:existing).key(actual)
      return unless key

      !exact_matches.include?(key) && !partial_matches.include?(key) &&
        !conflicts.include?(key) && problems[key].empty?
    end
  end

  matcher :be_an_exact_match do
    match do |actual|
      key = comparison.send(:existing).key(actual)
      exact_matches.include?(key) && problems[key].empty? if key
    end
  end

  matcher :be_a_partial_match do
    match do |actual|
      key = comparison.send(:existing).key(actual)
      partial_matches.include?(key) && problems[key].empty? if key
    end
  end

  matcher :be_a_conflict do
    match do |actual|
      key = comparison.send(:existing).key(actual)
      conflicts.include?(key) && problems[key].include?(@problem) if key
    end

    chain :with_problem do |problem|
      @problem = problem
    end
  end

  after do |ex|
    next unless ex.display_exception

    puts
    puts "statements: #{comparison.send(:existing).values}"
    puts "suggestion: #{comparison.send(:suggestion)}"
    puts "field_states: #{comparison.field_states}"
  end
end
