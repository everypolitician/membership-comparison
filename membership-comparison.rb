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
        state = statement_state(statement)
        next unless state
        h[state] ||= []
        h[state] << id
      end
    end

    def statement_state(statement)
      return unless statement[:position] == suggestion[:position]

      fields = %i[party district term start]
      field_matches = fields.map do |field|
        a = statement[field]
        b = suggestion[field]
        c = suggestion.fetch(:term, {})[:start]
        d = statement[:end]

        next :ignored if field == :term && a != b

        if field == :start
          next :conflict if a && c && d && a <= c && a < d
          next :partial if a && c && a <= c
        end

        if (a && b && a == b) || (!a && !b)
          :exact
        elsif (!a || !b) && a == b
          :partial
        elsif (a && b) && a != b
          :conflict
        end
      end

      if field_matches.include?(:conflict)
        :conflict
      elsif field_matches.include?(nil) || field_matches.include?(:partial)
        :partial
      elsif !field_matches.include?(:ignored)
        :exact
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  require 'minitest/autorun'
  require 'pry'

  class Minitest::Spec
    def self.test(desc, &block)
      define_method("test_#{desc}", &block)
    end
  end

  describe Wikidata::MembershipComparison do
    let(:mp) { { id: 'Q15964890' } }
    let(:speaker) { { id: 'Q2506685' } }
    let(:liberal) { { id: 'Q138345' } }
    let(:conservative) { { id: 'Q488523' } }
    let(:pontiac) { { id: 'Q3397734' } }
    let(:term41) { { id: 'Q2816776', start: '2011-06-02', end: '2015-08-02' } }
    let(:term42) { { id: 'Q21157957', start: '2015-12-03' } }
    let(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }

    test 'no existing P39s' do
      comparison = Wikidata::MembershipComparison.new(
        existing: {},
        suggestion: suggestion
      )
      comparison.exact_matches.must_equal []
      comparison.partial_matches.must_equal []
      comparison.conflicts.must_equal []
    end

    test 'single existing P39, previous term' do
      comparison = Wikidata::MembershipComparison.new(
        existing: {
          'wds:1030-1DAA-3100' => { position: mp, term: term41, party: liberal, district: pontiac }
        },
        suggestion: suggestion
      )
      comparison.exact_matches.must_equal []
      comparison.partial_matches.must_equal []
      comparison.conflicts.must_equal []
    end

    test 'single existing P39, exact match' do
      comparison = Wikidata::MembershipComparison.new(
        existing: {
          'wds:1030-1DAA-3101' => { position: mp, term: term42, party: liberal, district: pontiac }
        },
        suggestion: suggestion
      )
      comparison.exact_matches.must_equal ['wds:1030-1DAA-3101']
      comparison.partial_matches.must_equal []
      comparison.conflicts.must_equal []
    end

    test 'multiple existing P39s, one exact match' do
      comparison = Wikidata::MembershipComparison.new(
        existing: {
          'wds:1030-1DAA-3100' => { position: mp, term: term41, party: liberal, district: pontiac },
          'wds:1030-1DAA-3101' => { position: mp, term: term42, party: liberal, district: pontiac }
        },
        suggestion: suggestion
      )
      comparison.exact_matches.must_equal ['wds:1030-1DAA-3101']
      comparison.partial_matches.must_equal []
      comparison.conflicts.must_equal []
    end

    test 'single existing P39, partial match' do
      comparison = Wikidata::MembershipComparison.new(
        existing: {
          'wds:1030-1DAA-3102' => { position: mp, term: term42 }
        },
        suggestion: suggestion
      )
      comparison.exact_matches.must_equal []
      comparison.partial_matches.must_equal ['wds:1030-1DAA-3102']
      comparison.conflicts.must_equal []
    end

    test 'single existing P39, conflict' do
      comparison = Wikidata::MembershipComparison.new(
        existing: {
          'wds:1030-1DAA-3102' => { position: mp, term: term42, party: conservative }
        },
        suggestion: suggestion
      )
      comparison.exact_matches.must_equal []
      comparison.partial_matches.must_equal []
      comparison.conflicts.must_equal ['wds:1030-1DAA-3102']
    end

    test 'single existing P39, different position' do
      comparison = Wikidata::MembershipComparison.new(
        existing: {
          'wds:1030-1DAA-4100' => { position: speaker, term: term41, party: liberal, district: pontiac }
        },
        suggestion: suggestion
      )
      comparison.exact_matches.must_equal []
      comparison.partial_matches.must_equal []
      comparison.conflicts.must_equal []
    end

    test 'existing dated P39, within term' do
      comparison = Wikidata::MembershipComparison.new(
        existing: {
          'wds:1030-1DAA-3103' => { position: mp, start: '2015-12-03', party: liberal, district: pontiac }
        },
        suggestion: suggestion
      )
      comparison.exact_matches.must_equal []
      comparison.partial_matches.must_equal ['wds:1030-1DAA-3103']
      comparison.conflicts.must_equal []
    end

    test 'existing dated P39 between terms' do
      comparison = Wikidata::MembershipComparison.new(
        existing: {
          'wds:1030-1DAA-3104' => { position: mp, start: '2015-10-18', party: liberal, district: pontiac }
        },
        suggestion: suggestion
      )
      comparison.exact_matches.must_equal []
      comparison.partial_matches.must_equal ['wds:1030-1DAA-3104']
      comparison.conflicts.must_equal []
    end

    test 'existing dated P39 spanning terms' do
      comparison = Wikidata::MembershipComparison.new(
        existing: {
          'wds:1030-1DAA-3105' => { position: mp, start: '2011-06-02', end: '2017-11-12', party: liberal, district: pontiac }
        },
        suggestion: suggestion
      )
      comparison.exact_matches.must_equal []
      comparison.partial_matches.must_equal []
      comparison.conflicts.must_equal ['wds:1030-1DAA-3105']
    end
  end
end
