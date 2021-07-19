# frozen_string_literal: true

require_relative 'spec_helper'

describe Vulture::Util do
  before(:context) do
    RSpec::Mocks.with_temporary_scope do
      allow_any_instance_of(Vulture).to receive(:new).with(be_kind_of(Hash)).and_return(Vulture)
      @vulture = Vulture.new({ lang: 'php' })
    end
  end
  context '.get_manipulable_inputs' do
    it 'invalid file path' do
      expect { @vulture.get_manipulable_inputs('noexit_path') }.to raise_error(RuntimeError)
    end
    it 'invalid language' do
      file = File.expand_path(__FILE__)
      expect { @vulture.get_manipulable_inputs(file) }.to raise_error(RuntimeError)
    end

    it 'all is good' do
      file = "#{Vulture::RootInstall}/../examples/files_test/sqli.php"
      vars = @vulture.get_manipulable_inputs(File.readlines(file))
      expect(vars).not_to be(nil)
      expect(vars).not_to be_empty
    end
  end

  context '.get_patterns' do
    it 'invalid category' do
      expect { @vulture.get_patterns('invalid', 'php') }.to raise_error(RuntimeError)
    end
    it 'invalid language' do
      expect { @vulture.get_patterns('rce', 'noexist') }.to raise_error(RuntimeError)
    end
    it 'all is good' do
      patterns = @vulture.get_patterns('rce', 'php')
      expect(patterns).not_to be(nil)
      expect(patterns).to be_an_instance_of(Array)
    end
  end

  context '.generate_dynamic_patterns' do
    it 'all good' do
      patterns = @vulture.get_patterns('rce', 'php')
      file = "#{Vulture::RootInstall}/../examples/files_test/cmd.php"
      vars = @vulture.get_manipulable_inputs(File.readlines(file))

      regexs = @vulture.generate_dynamic_patterns(patterns, vars)

      expect(regexs).not_to be(nil)
      expect(regexs).not_to be_empty
    end
  end
end
