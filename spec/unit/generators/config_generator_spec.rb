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

  describe Howitzer::ConfigGenerator do
    let(:generator_name) { described_class }
    let(:expected_result) do
      [
        { name: '/config', is_directory: true },
        { name: '/config/boot.rb', is_directory: false, size: template_file_size('config', 'boot.rb') },
        { name: '/config/capybara.rb', is_directory: false, size: template_file_size('config', 'capybara.rb') },
        { name: '/config/custom.yml', is_directory: false, size: template_file_size('config', 'custom.yml') },
        { name: '/config/default.yml', is_directory: false, size: template_file_size('config', 'default.yml') }
      ]
    end

    it { is_expected.to eql(expected_result) }
    describe 'output' do
      let(:expected_output) do
        "  * Config files generation ...
      Added 'config/boot.rb' file
      Added 'config/custom.yml' file
      Added 'config/capybara.rb' file
      Added 'config/default.yml' file\n"
      end
      subject { output.string }
      it { is_expected.to eql(expected_output) }
    end
  end
end
