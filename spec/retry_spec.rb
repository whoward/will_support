require 'spec_helper'
require 'will_support/retry'

describe WillSupport::Retry do
  subject { instance }
  
  let(:instance) { described_class.new(**params) }
  
  let(:params) { Hash.new }
  
  describe '#attempts' do
    subject { super().attempts }
    
    it { is_expected.to eq 5 }

    context 'given a custom attempts count' do
      before { params[:attempts] = 10 }
      
      it { is_expected.to eq 10 }
    end
  end
  
  describe '#caught_exceptions' do
    subject { super().caught_exceptions }
    
    it { is_expected.to eq [StandardError] }
    
    context 'with a custom caught_exceptions array' do
      before { params[:caught_exceptions] = [StandardError, SyntaxError] }
      it { is_expected.to eq [StandardError, SyntaxError] }
    end
    
    context 'with a single custom caught_exception' do
      before { params[:caught_exceptions] = SyntaxError }
      it { is_expected.to eq [SyntaxError] }
    end
  end
  
  describe '#callbacks' do
    subject { super().callbacks }
    it { is_expected.to eq [] }
  end
  
  describe '#after_exception' do
    subject { super().after_exception(&block) }
    let(:block) { -> {} }
    
    # it is a chaining method
    it { is_expected.to eq instance }
    
    it 'appends the block to the callback list' do
      expect { subject }.to change(instance.callbacks, :length).by(1)
      expect(instance.callbacks).to eq [block]
    end
  end
  
  describe '#handle' do
    subject { super().handle(selector, &block) }
    let(:block) { -> {} }
    let(:selector) { StandardError }
    
    # it is a chaining method
    it { is_expected.to eq instance }
    
    it 'assigns the handler to the handlers hash' do
      expect(instance.handlers[StandardError]).to eq nil
      subject
      expect(instance.handlers[StandardError]).to eq block
    end
  end
  
  describe '#run' do
    subject { super().run(&block) }
    
    context 'with a proc that does not raise an exception' do
      let(:block) { -> {} }
      
      it 'will be called without raising an exception' do
        expect(block).to receive(:call).once.and_call_original
        
        expect { subject }.not_to raise_error
      end
    end
    
    context 'with a proc that does raise an exception' do
      let(:block) { -> { raise ArgumentError } }
      
      it 'will be called the maximum attempt number of times and then re-raise the exception' do
        expect(block).to receive(:call).exactly(5).times.and_call_original
        expect { subject }.to raise_error(ArgumentError)
      end
    end
    
    context 'with a proc that raises an exception not caught by #caught_exceptions' do
      let(:block) { -> { raise ArgumentError } }
      before { params[:caught_exceptions] = EOFError }
      
      it 'will be called once and re-raise the error' do
        expect(block).to receive(:call).once.and_call_original
        expect { subject }.to raise_error(ArgumentError)
      end
    end
    
    context 'when callbacks are defined' do
      let(:events) { Array.new }
      
      let(:block) { -> { events << :attempt && raise('failed') } }
      
      before { instance.after_exception { events << :callback } }
      
      it 'raises the exception but calls the callback after every attempt' do
        expect { subject }.to raise_error(RuntimeError)
        expect(events).to eq %i(attempt callback) * 5
      end
    end
    
    context 'when a class selector is defined that matches the exception raised' do
      before { instance.handle(RuntimeError, &handler_block) }
      
      let(:handler_block) { -> {} }
      
      let(:block) { -> { raise 'foo' } }
      
      it 'calls the handler block' do
        expect(handler_block).to receive(:call).exactly(5).times
        expect { subject }.to raise_error(RuntimeError)
      end
    end
    
    context 'when a proc selector is given that matches the exception raised' do
      before { instance.handle(matching_proc, &handler_proc) }
      
      let(:matching_proc) { -> (x) { x.is_a?(RuntimeError) } }
      
      let(:handler_proc) { -> {} }
      
      let(:block) { -> { raise 'foo' } }
      
      it 'calls the handler block' do
        expect(handler_proc).to receive(:call).exactly(5).times
        expect { subject }.to raise_error(RuntimeError)
      end
    end
    
    context 'when a class selector and a proc selector is given that both match the exception raised' do
      before { instance.handle(RuntimeError, &class_handler_proc) }
      before { instance.handle(matching_proc, &proc_handler_proc) }
      
      let(:matching_proc) { -> (x) { x.is_a?(RuntimeError) } }
      
      let(:class_handler_proc) { -> {} }
      
      let(:proc_handler_proc) { -> {} }
      
      let(:block) { -> { raise 'foo' } }
      
      it 'calls the handler for the proc selector, as they tend to be more specific than classes' do
        expect(proc_handler_proc).to receive(:call).exactly(5).times
        expect(class_handler_proc).not_to receive(:call)
        expect { subject }.to raise_error(RuntimeError)
      end
    end
    
    context 'when a class selector is given that is a superclass of the exception raised' do
      before { instance.handle(StandardError, &handler_proc) }
      
      let(:handler_proc) { -> {} }
      
      let(:block) { -> { raise 'foo' } }
      
      it 'calls the handler block' do
        expect(handler_proc).to receive(:call).exactly(5).times
        expect { subject }.to raise_error(RuntimeError)
      end
    end
    
    context 'when multiple class selectors are given that are ancestors of the exception raised' do
      before { instance.handle(Exception, &exception_handler_proc) }
      before { instance.handle(StandardError, &standard_error_handler_proc)  }
      
      let(:exception_handler_proc) { -> {} }
      let(:standard_error_handler_proc) { -> {} }
      
      let(:block) { -> { raise 'foo' } }
      
      it 'calls the closest matching class handler' do
        expect(standard_error_handler_proc).to receive(:call).exactly(5).times
        expect(exception_handler_proc).not_to receive(:call)
        expect { subject }.to raise_error(RuntimeError)
      end
    end
  end
  
end