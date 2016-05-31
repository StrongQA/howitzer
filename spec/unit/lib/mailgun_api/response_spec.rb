require 'spec_helper'
require 'howitzer/mailgun_api/client'
require 'howitzer/exceptions'

RSpec.describe Howitzer::MailgunApi::Response do
  let(:body) { { foo: 'bar' }.to_json }
  let(:response) { double(:response, body: body, code: 201) }
  describe '#body' do
    subject { described_class.new(response).body }
    it { is_expected.to eq('{"foo":"bar"}') }
  end
  describe '#code' do
    subject { described_class.new(response).code }
    it { is_expected.to eq(201) }
  end
  describe '#to_h' do
    subject { described_class.new(response).to_h }
    context 'when possible parse body' do
      it { is_expected.to eq('foo' => 'bar') }
    end
    context 'when impossible parse body' do
      let(:body) { '123' }
      it do
        expect(log).to receive(:error).with(Howitzer::ParseError, any_args)
          .once.and_call_original
        expect { subject }.to raise_error(Howitzer::ParseError)
      end
    end
  end
end
