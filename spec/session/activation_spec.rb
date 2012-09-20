require 'spec_helper'

describe GoogleAuthenticatorRails::Session::Base do
  describe 'ClassMethods' do
    context 'thread safety' do
      let(:thread_count) { 100 }
      let(:controllers)  { thread_count.times.map { MockController.new } }
      let(:threads) do
        controllers.map do |controller|
          Thread.new do
            GoogleAuthenticatorRails::Session::Base.controller = controller
            Thread.current[:test_case_controller] = GoogleAuthenticatorRails::Session::Base.controller
          end
        end
      end

      before do
        GoogleAuthenticatorRails::Session::Base.controller = nil
        sleep(0.01) while threads.any?(&:status)
      end

      specify { GoogleAuthenticatorRails::Session::Base.controller.should be_nil }
      specify { threads.map { |thread| thread[:test_case_controller].object_id }.should eq controllers.map(&:object_id) }
    end

    describe '#activated?' do
      subject { GoogleAuthenticatorRails::Session::Base }

      context 'controller present' do
        before  { GoogleAuthenticatorRails::Session::Base.controller = MockController.new }

        its(:activated?) { should be true }
      end

      context 'controller missing' do
        before  { GoogleAuthenticatorRails::Session::Base.controller = nil }

        its(:activated?) { should be false }
      end
    end
  end

  describe 'InstanceMethods' do
    describe '#initialize' do
      context 'controller missing' do
        before  { GoogleAuthenticatorRails::Session::Base.controller = nil }
        specify { lambda { GoogleAuthenticatorRails::Session::Base.new(nil) }.should raise_error(GoogleAuthenticatorRails::Session::Activation::ControllerMissingError) }
      end
    end
  end
end