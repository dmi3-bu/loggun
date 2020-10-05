require 'spec_helper'

RSpec.describe ApiController, type: :controller do
  describe '#index' do
    let!(:pattern) { 'rails_modifier_enabled' }
    let!(:start_pattern) { 'http_requests.outgoing.start' }
    let!(:response_pattern) { 'http_requests.outgoing.response' }

    let!(:rails_modifier_enabled) { false }

    subject { get(:index) }

    before do
      Loggun::Config.configure do |config|
        config.pattern = pattern
        config.modifiers.rails = rails_modifier_enabled
        # config.modifiers.outgoing_http = rails_modifier_enabled
      end
    end

    it 'does not enable modifier' do
      expect { subject }.not_to output(/#{pattern}/).to_stdout_from_any_process
    end

    context 'when modifier enabled' do
      let!(:rails_modifier_enabled) { true }

      it 'enabled modifier' do
        expect { subject }.to output(/#{pattern}/).to_stdout_from_any_process
      end

      # it 'enabled modifier' do
      #   expect { subject }.to output(/#{start_pattern}/).to_stdout_from_any_process
      # end
      #
      # it 'enabled modifier' do
      #   expect { subject }.to output(/#{response_pattern}/).to_stdout_from_any_process
      # end
    end
  end

  describe '#outgoing_request' do
    let!(:start_pattern) { 'http_requests.outgoing.start' }
    let!(:response_pattern) { 'http_requests.outgoing.response' }

    let!(:modifier_enabled) { false }

    subject { get(:outgoing_request) }

    before do
      Loggun::Config.configure do |config|
        config.pattern = ''
        config.modifiers.rails = false
        config.modifiers.outgoing_http = modifier_enabled
      end
    end

    it 'does not enable modifier' do
      expect { subject }.not_to output(/#{start_pattern}/).to_stdout_from_any_process
      expect { subject }.not_to output(/#{response_pattern}/).to_stdout_from_any_process
    end

    context 'when modifier enabled' do
      let!(:modifier_enabled) { true }

      it 'enabled modifier' do
        expect { subject }.to output(/#{start_pattern}/).to_stdout_from_any_process
      end

      it 'enabled modifier' do
        expect { subject }.to output(/#{response_pattern}/).to_stdout_from_any_process
      end
    end
  end

  pending '#incoming_request' do
    let!(:start_pattern) { 'http_requests.outgoing.start' }
    let!(:response_pattern) { 'http_requests.outgoing.response' }

    let!(:modifier_enabled) { false }

    subject { get(:incoming_request) }

    before do
      Loggun::Config.configure do |config|
        config.modifiers.incoming_http.enable = true
        config.modifiers.incoming_http.controllers = ['ApplicationController']
        config.modifiers.incoming_http.success_condition = -> { response.code == '200' }
        config.modifiers.incoming_http.error_info = -> { nil }
      end
    end

    it 'does not enable modifier' do
      expect { subject }.not_to output(/#{start_pattern}/).to_stdout_from_any_process
      expect { subject }.not_to output(/#{response_pattern}/).to_stdout_from_any_process
    end

    context 'when modifier enabled' do
      let!(:modifier_enabled) { true }

      it 'enabled modifier' do
        expect { subject }.to output(/#{start_pattern}/).to_stdout_from_any_process
      end

      it 'enabled modifier' do
        expect { subject }.to output(/#{response_pattern}/).to_stdout_from_any_process
      end
    end
  end
end