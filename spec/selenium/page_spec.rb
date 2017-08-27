# frozen_string_literal: true

require 'spec_helper'
require 'will_support/selenium'

describe WillSupport::Selenium::Page do
  subject { klass }

  let(:klass) { Class.new(described_class) }

  describe '.selectors' do
    subject { super().selectors }
    it { is_expected.to be_an_instance_of Hash }
  end

  describe '.parser' do
    subject { super().parser(&class_definition) }

    let(:class_definition) { proc {} }

    it { is_expected.to be_an_instance_of Class }
    its(:superclass) { is_expected.to eq Nokogiri::HTML::Document }

    context 'when the class has defined methods' do
      let(:class_definition) { proc { define_method(:foo) {} } }

      its(:instance_methods) { is_expected.to include :foo }
    end
  end

  describe '.element' do
    before { subject.element(:name_field, css: 'form input[name=foo]') }

    its(:instance_methods) { is_expected.to include :name_field }

    it 'assigns the selector record for the element name' do
      expect(subject.selectors[:name_field]).to be_an_instance_of WillSupport::Selenium::Selector
    end

    it 'raises an exception if the element is already defined' do
      expect { subject.element(:name_field, id: 'foo') }.to raise_error(RuntimeError)
    end
  end

  describe '.presence_finder' do
    before { subject.presence_finder(id: 'foo') }

    it 'assigns the presence_finder selector' do
      expect(subject.selectors[:presence_finder]).to be_an_instance_of WillSupport::Selenium::Selector
    end
  end

  context 'on an instance' do
    subject { super().new(webdriver) }

    let(:webdriver) { double('WebDriver') }

    context 'with an element named :name_field defined' do
      before { subject.class.element(:name_field, id: 'foo') }

      it { is_expected.to respond_to :name_field }

      its(:name_field) { is_expected.to be_an_instance_of(WillSupport::Selenium::Element) }
    end

    describe '#parser' do
      subject { super().parser }

      before { expect(webdriver).to receive(:page_source).and_return(document) }

      let(:document) do
        <<-EOS
          <html>
            <head>
              <title>Hello World</title>
            </head>
            <body></body>
          </html>
        EOS
      end

      it { is_expected.to be_an_instance_of(Nokogiri::HTML::Document) }

      context 'given a class with a custom parser' do
        before do
          klass.parser do
            def title
              at_css('title').text
            end
          end
        end

        its(:title) { is_expected. to eq 'Hello World' }
      end
    end

    describe '#present?' do
      subject { super().present? }

      context 'given a page with no presence_finder defined' do
        it { is_expected.to eq false }
      end

      context 'given a page with a presence_finder that matches an element on the page' do
        before { klass.element(:presence_finder, id: 'foo') }

        before { expect(webdriver).to receive(:find_element).with(:id, 'foo').and_return(element) }

        let(:element) { double('Selenium Element') }

        it { is_expected.to eq true }
      end

      context 'given a page with a presence_finder that doesnt match an element on the page' do
        before { klass.element(:presence_finder, id: 'foo') }

        before do
          expect(webdriver).to receive(:find_element)
            .with(:id, 'foo')
            .and_raise(Selenium::WebDriver::Error::NoSuchElementError)
        end

        it { is_expected.to eq false }
      end
    end
  end
end
