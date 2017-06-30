require 'spec_helper'

RSpec.describe 'Generators' do
  let(:destination) { Howitzer::BaseGenerator.destination }
  let(:output) { StringIO.new }
  subject { file_tree_info(destination) }
  before do
    Howitzer::BaseGenerator.logger = output
    generator_name.new({})
  end
  after { FileUtils.rm_r(destination) }

  describe Howitzer::EmailsGenerator do
    let(:generator_name) { described_class }
    let(:expected_result) do
      [
        { name: '/emails', is_directory: true },
        {
          name: '/emails/example_email.rb',
          is_directory: false,
          size: template_file_size('emails', 'example_email.rb')
        }
      ]
    end
    it { is_expected.to eql(expected_result) }
    describe 'output' do
      let(:expected_output) do
        "#{ColorizedString.new('  * Email example generation ...').light_cyan}
      #{ColorizedString.new('Added').light_green} '/emails/example_email.rb' file\n"
      end
      subject { output.string }
      it { is_expected.to eql(expected_output) }
    end
  end
end
