require 'spec_helper'
require 'sidekiq/testing'

RSpec.describe LoggerWorker, type: :worker do
  describe '#perform' do
    let!(:pattern) { 'rails_modifier_enabled' }
    let!(:sidekiq_modifier_enabled) { false }

    subject do
      Sidekiq::Testing.inline! do
        described_class.perform_async
      end
    end

    before do
      Loggun::Config.configure do |config|
        config.pattern = pattern
        config.modifiers.rails = true
        config.modifiers.sidekiq = sidekiq_modifier_enabled
      end
    end

    it 'does not enable modifier' do
      expect { subject }.not_to output(/#{pattern}/).to_stdout_from_any_process
    end

    context 'when modifier enabled' do
      let!(:sidekiq_modifier_enabled) { true }

      it 'enabled modifier' do
        expect { subject }.to output(/#{pattern}/).to_stdout_from_any_process
      end
    end
  end
end
