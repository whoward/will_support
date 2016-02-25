require 'spec_helper'
require 'will_support/selenium'

describe WillSupport::Selenium::Element do
  subject { described_class.new(webdriver, :css, 'body#feed') }
  
  let(:webdriver) { double('Selenium WebDriver') }
  let(:element) { double('Selenium Element') }
  
  before { allow(webdriver).to receive(:find_element).with(:css, 'body#feed').and_return(element) }
  
  describe '#fetch!' do
    subject { super().fetch! }
    it { is_expected.to eq element }
  end
  
  describe '#text' do
    subject { super().text }
    let(:element) { double(text: 'Hello World') }
    it { is_expected.to eq 'Hello World' }
  end
  
  describe '#send_keys' do
    subject { super().send_keys('Hello') }
    
    it 'proxies them to the selenium element' do
      expect(element).to receive(:send_keys).with('Hello')
      subject
    end
  end
end