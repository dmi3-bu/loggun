require_relative 'rails_helper'

RSpec.describe Rails do
  it 'has default formatter' do
    expect(described_class.logger.formatter.class)
      .to eq(ActiveSupport::Logger::SimpleFormatter)
  end

  context 'when loggun modifier enabled' do
    before { Loggun::Config.setup_formatter(Rails) }

    it 'has Loggun formatter' do
      expect(described_class.logger.formatter.class)
        .to eq(Loggun::Formatter)
    end
  end
end