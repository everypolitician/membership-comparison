module Membership
  class Comparison
    def initialize(existing:, suggestion:)
      @existing = existing
      @suggestion = suggestion
    end

    def exact_matches
      []
    end

    def partial_matches
      []
    end

    def conflicts
      []
    end

    private

    attr_reader :existing, :suggestion
  end
end

if $PROGRAM_NAME == __FILE__
  require 'minitest/autorun'

  class Minitest::Spec
    def self.test(desc, &block)
      define_method("test_#{desc}", &block)
    end
  end

  describe Membership::Comparison do

    let(:mp) { { id: 'Q15964890' }.freeze }
    let(:speaker) { { id: 'Q2506685' }.freeze }
    let(:liberal) { { id: 'Q138345' }.freeze }
    let(:conservative) { { id: 'Q488523' }.freeze }
    let(:pontiac) { { id: 'Q3397734' }.freeze }
    let(:term41) { { id: 'Q2816776', start: '2011-06-02', end: '2015-08-02' } }
    let(:term42) { { id: 'Q21157957', start: '2015-12-03' } }
    let(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }

    test 'no existing P39s' do
      comparison = Membership::Comparison.new(
        existing: [],
        suggestion: suggestion
      )
      comparison.exact_matches.must_equal []
      comparison.partial_matches.must_equal []
      comparison.conflicts.must_equal []
    end

    test 'single existing P39, previous term' do
      comparison = Membership::Comparison.new(
        existing: [
          'wds:1030-1DAA-3100' => { position: mp, term: term41, party: liberal, district: pontiac }
        ],
        suggestion: suggestion
      )
      comparison.exact_matches.must_equal []
      comparison.partial_matches.must_equal []
      comparison.conflicts.must_equal []
    end

    test 'single existing P39, exact match' do
      comparison = Membership::Comparison.new(
        existing: [
          'wds:1030-1DAA-3101' => { position: mp, term: term42, party: liberal, district: pontiac }
        ],
        suggestion: suggestion
      )
      comparison.exact_matches.must_equal ['wds:1030-1DAA-3101']
      comparison.partial_matches.must_equal []
      comparison.conflicts.must_equal []
    end

    test 'multiple existing P39s, one exact match' do
      comparison = Membership::Comparison.new(
        existing: [
          'wds:1030-1DAA-3100' => { position: mp, term: term41, party: liberal, district: pontiac },
          'wds:1030-1DAA-3101' => { position: mp, term: term42, party: liberal, district: pontiac }
        ],
        suggestion: suggestion
      )
      comparison.exact_matches.must_equal ['wds:1030-1DAA-3101']
      comparison.partial_matches.must_equal []
      comparison.conflicts.must_equal []
    end

    test 'single existing P39, partial match' do
      comparison = Membership::Comparison.new(
        existing: [
          'wds:1030-1DAA-3102' => { position: mp, term: term42 }
        ],
        suggestion: suggestion
      )
      comparison.exact_matches.must_equal []
      comparison.partial_matches.must_equal ['wds:1030-1DAA-3102']
      comparison.conflicts.must_equal []
    end

    test 'single existing P39, conflict' do
      comparison = Membership::Comparison.new(
        existing: [
          'wds:1030-1DAA-3102' => { position: mp, term: term42, party: conservative }
        ],
        suggestion: suggestion
      )
      comparison.exact_matches.must_equal []
      comparison.partial_matches.must_equal []
      comparison.conflicts.must_equal ['wds:1030-1DAA-3102']
    end

    test 'single existing P39, different position' do
      comparison = Membership::Comparison.new(
        existing: [
          'wds:1030-1DAA-4100' => { position: speaker, term: term41, party: liberal, district: pontiac }
        ],
        suggestion: suggestion
      )
      comparison.exact_matches.must_equal []
      comparison.partial_matches.must_equal []
      comparison.conflicts.must_equal []
    end

    test 'existing dated P39, within term' do
      comparison = Membership::Comparison.new(
        existing: [
          'wds:1030-1DAA-3103' => { position: mp, start: '2015-12-03', party: liberal, district: pontiac }
        ],
        suggestion: suggestion
      )
      comparison.exact_matches.must_equal []
      comparison.partial_matches.must_equal ['wds:1030-1DAA-3103']
      comparison.conflicts.must_equal []
    end

    test 'existing dated P39 between terms' do
      comparison = Membership::Comparison.new(
        existing: [
          'wds:1030-1DAA-3104' => { position: mp, start: '2015-10-18', party: liberal, district: pontiac }
        ],
        suggestion: suggestion
      )
      comparison.exact_matches.must_equal []
      comparison.partial_matches.must_equal ['wds:1030-1DAA-3104']
      comparison.conflicts.must_equal []
    end

    test 'existing dated P39 spanning terms' do
      comparison = Membership::Comparison.new(
        existing: [
          'wds:1030-1DAA-3105' => { position: mp, start: '2011-06-02', end: '2017-11-12', party: liberal, district: pontiac }
        ],
        suggestion: suggestion
      )
      comparison.exact_matches.must_equal []
      comparison.partial_matches.must_equal []
      comparison.conflicts.must_equal ['wds:1030-1DAA-3105']
    end
  end
end
