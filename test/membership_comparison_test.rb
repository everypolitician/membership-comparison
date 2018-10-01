# frozen_string_literal: true

require_relative './test_helper'

describe Wikidata::MembershipComparison do
  let(:mp) { { id: 'Q15964890' } }
  let(:speaker) { { id: 'Q2506685' } }
  let(:liberal) { { id: 'Q138345' } }
  let(:conservative) { { id: 'Q488523' } }
  let(:pontiac) { { id: 'Q3397734' } }
  let(:term41) { { id: 'Q2816776', start: '2011-06-02', end: '2015-08-02' } }
  let(:term42) { { id: 'Q21157957', start: '2015-12-03' } }
  let(:suggestion) { { position: mp, term: term42, party: liberal, district: pontiac } }
  let(:suggestion41) { { position: mp, term: term41, party: liberal, district: pontiac } }

  it 'no existing P39s' do
    comparison = Wikidata::MembershipComparison.new(
      existing:   {},
      suggestion: suggestion
    )
    comparison.exact_matches.must_equal []
    comparison.partial_matches.must_equal []
    comparison.conflicts.must_equal []
  end

  it 'single existing P39, previous term' do
    comparison = Wikidata::MembershipComparison.new(
      existing:   {
        'wds:1030-1DAA-3100' => { position: mp, term: term41, party: liberal, district: pontiac },
      },
      suggestion: suggestion
    )
    comparison.exact_matches.must_equal []
    comparison.partial_matches.must_equal []
    comparison.conflicts.must_equal []
  end

  it 'single existing P39, following term' do
    comparison = Wikidata::MembershipComparison.new(
      existing:   {
        'wds:1030-1DAA-3101' => { position: mp, term: term42, party: liberal, district: pontiac },
      },
      suggestion: suggestion41
    )
    comparison.exact_matches.must_equal []
    comparison.partial_matches.must_equal []
    comparison.conflicts.must_equal []
  end

  it 'single existing P39, exact match' do
    comparison = Wikidata::MembershipComparison.new(
      existing:   {
        'wds:1030-1DAA-3101' => { position: mp, term: term42, party: liberal, district: pontiac },
      },
      suggestion: suggestion
    )
    comparison.exact_matches.must_equal ['wds:1030-1DAA-3101']
    comparison.partial_matches.must_equal []
    comparison.conflicts.must_equal []
  end

  it 'multiple existing P39s, current exact match' do
    comparison = Wikidata::MembershipComparison.new(
      existing:   {
        'wds:1030-1DAA-3100' => { position: mp, term: term41, party: liberal, district: pontiac },
        'wds:1030-1DAA-3101' => { position: mp, term: term42, party: liberal, district: pontiac },
      },
      suggestion: suggestion
    )
    comparison.exact_matches.must_equal ['wds:1030-1DAA-3101']
    comparison.partial_matches.must_equal []
    comparison.conflicts.must_equal []
  end

  it 'multiple existing P39s, historic exact match' do
    comparison = Wikidata::MembershipComparison.new(
      existing:   {
        'wds:1030-1DAA-3100' => { position: mp, term: term41, party: liberal, district: pontiac },
        'wds:1030-1DAA-3101' => { position: mp, term: term42, party: liberal, district: pontiac },
      },
      suggestion: suggestion41
    )
    comparison.exact_matches.must_equal ['wds:1030-1DAA-3100']
    comparison.partial_matches.must_equal []
    comparison.conflicts.must_equal []
  end

  it 'single existing P39, partial match' do
    comparison = Wikidata::MembershipComparison.new(
      existing:   {
        'wds:1030-1DAA-3102' => { position: mp, term: term42 },
      },
      suggestion: suggestion
    )
    comparison.exact_matches.must_equal []
    comparison.partial_matches.must_equal ['wds:1030-1DAA-3102']
    comparison.conflicts.must_equal []
  end

  it 'single existing P39, conflict' do
    comparison = Wikidata::MembershipComparison.new(
      existing:   {
        'wds:1030-1DAA-3102' => { position: mp, term: term42, party: conservative },
      },
      suggestion: suggestion
    )
    comparison.exact_matches.must_equal []
    comparison.partial_matches.must_equal []
    comparison.conflicts.must_equal ['wds:1030-1DAA-3102']
  end

  it 'single existing P39, different position' do
    comparison = Wikidata::MembershipComparison.new(
      existing:   {
        'wds:1030-1DAA-4100' => { position: speaker, term: term41, party: liberal, district: pontiac },
      },
      suggestion: suggestion
    )
    comparison.exact_matches.must_equal []
    comparison.partial_matches.must_equal []
    comparison.conflicts.must_equal []
  end

  it 'existing dated P39, within term' do
    comparison = Wikidata::MembershipComparison.new(
      existing:   {
        'wds:1030-1DAA-3103' => { position: mp, start: '2015-12-03', party: liberal, district: pontiac },
      },
      suggestion: suggestion
    )
    comparison.exact_matches.must_equal []
    comparison.partial_matches.must_equal ['wds:1030-1DAA-3103']
    comparison.conflicts.must_equal []
  end

  it 'existing dated P39 between terms' do
    comparison = Wikidata::MembershipComparison.new(
      existing:   {
        'wds:1030-1DAA-3104' => { position: mp, start: '2015-10-18', party: liberal, district: pontiac },
      },
      suggestion: suggestion
    )
    comparison.exact_matches.must_equal []
    comparison.partial_matches.must_equal ['wds:1030-1DAA-3104']
    comparison.conflicts.must_equal []
  end

  it 'existing dated P39 spanning terms' do
    comparison = Wikidata::MembershipComparison.new(
      existing:   {
        'wds:1030-1DAA-3105' => { position: mp, start: '2011-06-02', end: '2017-11-12', party: liberal,
                                  district: pontiac, },
      },
      suggestion: suggestion
    )
    comparison.exact_matches.must_equal []
    comparison.partial_matches.must_equal []
    comparison.conflicts.must_equal ['wds:1030-1DAA-3105']
  end
end
