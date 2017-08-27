# frozen_string_literal: true

require 'spec_helper'
require 'will_support/selenium'

describe WillSupport::Selenium::PageCollection do
  subject { mod }

  let(:mod) { Module.new }

  before { mod.extend(described_class) }

  describe '#define' do
    subject { super().define(name, &proc {}) }

    let(:name) { :point_of_sale }

    it { is_expected.to be_a Class }

    its(:superclass) { is_expected.to eq WillSupport::Selenium::Page }

    it { is_expected.to eq mod::PointOfSale }

    describe 'created accessor method' do
      subject { super() && mod.point_of_sale }

      it { is_expected.to eq mod::PointOfSale }
    end
  end
end
