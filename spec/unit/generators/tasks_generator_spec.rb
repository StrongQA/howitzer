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

  describe Howitzer::TasksGenerator do
    let(:generator_name) { described_class }
    let(:expected_result) do
      [
        { name: '/tasks', is_directory: true },
        { name: '/tasks/common.rake', is_directory: false, size: template_file_size('tasks', 'common.rake') }
      ]
    end
    it { is_expected.to eql(expected_result) }
    describe 'output' do
      let(:expected_output) do
        "#{ColorizedString.new('  * Base rake task generation ...').light_cyan}
      #{ColorizedString.new('Added').light_green} 'tasks/common.rake' file\n"
      end
      subject { output.string }
      it { is_expected.to eql(expected_output) }
    end
  end
end
