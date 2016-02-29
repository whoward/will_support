require 'spec_helper'
require 'will_support/service'

describe WillSupport::Service::Object do
  subject { TestServiceObject }
  
  class TestServiceObject
    include WillSupport::Service::Object
    
    def passes
      Success(true)
    end
    service_method :passes
    
    service_method(:fails) do
      Failure(false)
    end
    
    service_method(:returns_nil) do
      nil
    end
    
    service_method(:returns_false) do
      false
    end
    
    service_method(:returns_true) do
      true
    end
  end
  
  shared_examples 'a successful service response' do |expected_value|
    it { is_expected.to be_success }
    its(:value) { is_expected.to eq expected_value }
    it { is_expected.to be_an_instance_of Deterministic::Result::Success }
  end
  
  shared_examples 'a failing service response' do |expected_value|
    it { is_expected.to be_failure }
    its(:value) { is_expected.to eq expected_value }
    it { is_expected.to be_an_instance_of Deterministic::Result::Failure }
  end
  
  describe '.service_method' do
    subject { super().new }
    
    it { is_expected.to respond_to :passes }
    it { is_expected.to respond_to :fails }
    it { is_expected.to respond_to :passes! }
    it { is_expected.to respond_to :fails! }
    
    it 'returns the symbol name of the method created' do
      expect(TestServiceObject.service_method(:foo) {}).to eq :foo
    end
    
    describe '#passes' do
      subject { super().passes }
      it_behaves_like 'a successful service response', true
    end
    
    describe '#fails' do
      subject { super().fails }
      it_behaves_like 'a failing service response', false
    end
    
    describe '#passes!' do
      subject { super().passes! }
      it_behaves_like 'a successful service response', true
    end
    
    describe '#fails!' do
      subject { super().fails! }
      it 'raises an exception' do
        expect { subject }.to raise_error WillSupport::Service::Error
      end
    end
    
    describe '#returns_nil' do
      subject { super().returns_nil }
      it_behaves_like 'a failing service response', nil
    end
    
    describe '#returns_false' do
      subject { super().returns_false }
      it_behaves_like 'a failing service response', false
    end
    
    describe '#returns_true' do
      subject { super().returns_true }
      it_behaves_like 'a successful service response', true
    end
  end
end