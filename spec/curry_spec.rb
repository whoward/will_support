# frozen_string_literal: true
require 'spec_helper'
require 'will_support/curry'

describe WillSupport::Curry do
  shared_examples 'have the curried methods' do
    describe '#zero' do
      subject { super().zero }
  
      it { is_expected.to respond_to(:call) }
  
      describe 'calling' do
        subject { super().call }
        it { is_expected.to eq 0 }
      end
    end
  
    describe '#one' do
      it 'can be called with ()' do
        expect(subject.one(1)).to eq 1
      end
      
      context 'when curried' do
        subject { super().one }
    
        it { is_expected.to respond_to(:call) }
    
        describe 'calling with #call' do
          subject { super().call(1) }
          it { is_expected.to eq 1 }
        end
    
        describe 'calling with []' do
          subject { super()[1] }
          it { is_expected.to eq 1 }
        end
      end
    end
  
    describe '#two' do
      it 'can be called with ()' do
        expect(subject.two(1,2)).to eq 3
      end
      
      context 'when curried' do
        subject { super().two }
    
        it { is_expected.to respond_to(:call) }
    
        describe 'calling with #call' do
          subject { super().call(1, 2) }
          it { is_expected.to eq 3 }
        end
    
        describe 'calling with []' do
          subject { super()[1, 2] }
          it { is_expected.to eq 3 }
        end
    
        describe 'calling with [] and #call' do
          subject { super()[1].call(2) }
          it { is_expected.to eq 3 }
        end
      end
    end
  
    describe 'uncurried methods' do
      it { is_expected.to respond_to :uncurried_zero }
      it { is_expected.to respond_to :uncurried_one }
      it { is_expected.to respond_to :uncurried_two }
  
      describe '#uncurried_zero' do
        subject { super().uncurried_zero }
        it { is_expected.to eq 0 }
      end
  
      describe '#uncurried_one' do
        subject { super().uncurried_one(1) }
        it { is_expected.to eq 1 }
      end
  
      describe '#uncurried_two' do
        subject { super().uncurried_two(1, 2) }
        it { is_expected.to eq 3 }
      end
    end
  end
  
  module TestModule
    extend WillSupport::Curry

    module_function

    curry def zero
      0
    end

    curry def one(x)
      x
    end

    curry def two(x, y)
      x + y
    end
  end
  
  class CurriedClass
    extend WillSupport::Curry
    
    curry def zero
      0
    end

    curry def one(x)
      x
    end

    curry def two(x, y)
      x + y
    end
  end
  
  context 'when being extended in a module' do
    subject { TestModule }
    
    include_examples 'have the curried methods'
  end
  
  context 'when extending class instance methods' do
    subject { CurriedClass.new }
    
    include_examples 'have the curried methods'
  end
end
