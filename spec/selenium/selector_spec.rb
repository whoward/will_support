# frozen_string_literal: true

require 'spec_helper'
require 'will_support/selenium'

describe WillSupport::Selenium::Selector do
  subject { described_class.new(**params) }

  let(:params) { {} }

  describe '#initialize' do
    context 'given a css selector' do
      before { params[:css] = 'body#foo' }
      it 'doesnt raise an exception' do
        expect { subject }.not_to raise_error
      end
    end

    context 'given an id selector' do
      before { params[:id] = 'foo' }
      it 'doesnt raise an exception' do
        expect { subject }.not_to raise_error
      end
    end

    context 'given an xpath selector' do
      before { params[:xpath] = '/foo/bar' }
      it 'doesnt raise an exception' do
        expect { subject }.not_to raise_error
      end
    end

    context 'given no selector' do
      it 'raises an exception' do
        expect { subject }.to raise_error ArgumentError
      end
    end
  end

  describe '#new' do
    subject { super().new(webdriver).fetch! }

    let(:webdriver) { double('Selenium WebDriver') }

    let(:element) { double('Selenium Element') }

    context 'given a css selector' do
      before do
        params[:css] = 'body#foo'
        expect(webdriver).to receive(:find_element).with(:css, 'body#foo').and_return(element)
      end
      it { is_expected.to eq element }
    end

    context 'given an id selector' do
      before do
        params[:id] = 'foo'
        expect(webdriver).to receive(:find_element).with(:id, 'foo').and_return(element)
      end
      it { is_expected.to eq element }
    end

    context 'given an xpath selector' do
      before do
        params[:xpath] = '/foo/bar'
        expect(webdriver).to receive(:find_element).with(:xpath, '/foo/bar').and_return(element)
      end
      it { is_expected.to eq element }
    end
  end
end
