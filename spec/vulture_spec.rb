
require 'spec_helper'
require 'pry'
describe Vulture do

  it "has a version number" do
    expect(Vulture::VERSION).not_to be nil
  end

  context 'initialize' do
    it 'instance variable' do
      # lang is required
      expect{ Vulture.new }.to raise_error(RuntimeError)
      expect(Vulture.new({:lang => 'mock'})).to be_instance_of(Vulture)

    end
    it 'invalid scan type should raise an exception' do
      expect{ Vulture.new({ :lang => 'mock', :rot => 'invalid' }) }.to raise_error(RuntimeError)
    end
  end

  context '.to_analize' do
    it 'perform a analize for a specific category' do
      allow_any_instance_of(Vulture).to receive(:new).and_return(Vulture)
      vulture = Vulture.new({
          :rot => 'rce',
          :lang => 'php',
      })
      vulture.patterns = vulture.get_patterns('rce', 'php')
      vulture.file = "#{Vulture::RootInstall}/../examples/files_test/cmd.php"
      vars = vulture.get_manipulable_inputs(File.readlines(vulture.file))
      vulture.patterns = vulture.generate_dynamic_patterns(vulture.patterns, vars)
      result = vulture.to_analyze()
      expect(result).not_to be(nil)
      expect(result).to be_an_instance_of(Array)
    end
    it 'invalid category' do
      allow_any_instance_of(Vulture).to receive(:new).and_return(Vulture)
      expect{ Vulture.new({:lang => 'mock', :rot => 'invalid'}) }.to raise_error(RuntimeError)
    end
  end

end
