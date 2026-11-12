# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'open3'
require 'tmpdir'

RSpec.describe 'bin/switch_ig_version.sh' do
  root = File.expand_path('../..', __dir__)
  tracked = %w[config.json lib/gpccmp_test_kit.rb resources/init-bundles/gpccmp-package.json].freeze
  old_version = JSON.parse(File.read(File.join(root, 'config.json'))).dig('ig', 'version')
  new_version = '9.8.7-made-up'

  # A scratch kit: the real version-bearing files, plus stand-ins for the artefacts.
  around do |example|
    Dir.mktmpdir do |kit|
      tracked.each do |path|
        FileUtils.mkdir_p(File.join(kit, File.dirname(path)))
        FileUtils.cp(File.join(root, path), File.join(kit, path))
      end
      FileUtils.mkdir_p(File.join(kit, 'lib/gpccmp_test_kit/igs'))
      FileUtils.touch(File.join(kit, "lib/gpccmp_test_kit/igs/#{old_version}.tgz"))
      FileUtils.touch(File.join(kit, "lib/gpccmp_test_kit/igs/#{new_version}.tgz"))
      FileUtils.mkdir_p(File.join(kit, "lib/gpccmp_test_kit/generated/v#{old_version}/patient"))
      @kit = kit
      example.run
    end
  end

  let(:script) { File.join(root, 'bin/switch_ig_version.sh') }

  def switch(*args)
    Open3.capture2e(script, *args, chdir: @kit)
  end

  def kit_file(path)
    File.read(File.join(@kit, path))
  end

  context 'when switching to a new version' do
    before do
      output, status = switch(old_version, new_version)
      raise output unless status.success?
    end

    it 'points every version field of config.json at the new version' do
      config = JSON.parse(kit_file('config.json'))

      expect(config.dig('ig', 'version')).to eq(new_version)
      expect(config.dig('ig', 'package_archive_path')).to eq("lib/gpccmp_test_kit/igs/#{new_version}.tgz")
      expect(config.dig('suite', 'rewrite_igs')).to eq("/home/igs/#{new_version}.tgz")
    end

    it 'changes nothing else in config.json' do
      before = File.read(File.join(root, 'config.json'))

      expect(kit_file('config.json').gsub(new_version, old_version)).to eq(before)
    end

    it 'requires the new suite from the kit entry point, and only that one' do
      requires = kit_file('lib/gpccmp_test_kit.rb').lines.grep(/require_relative/)

      expect(requires.map(&:strip))
        .to eq(["require_relative 'gpccmp_test_kit/generated/v#{new_version}/gpccmp_test_suite'"])
    end

    it 'points the Aidbox init bundle at the new archive and changes nothing else in it' do
      before = File.read(File.join(root, 'resources/init-bundles/gpccmp-package.json'))
      bundle = kit_file('resources/init-bundles/gpccmp-package.json')

      expect(bundle).to include("file:///resources/ig/#{new_version}.tgz")
      expect(bundle.sub("#{new_version}.tgz", "#{old_version}.tgz")).to eq(before)
    end

    it 'removes the previous archive and generated suite, and keeps the new archive' do
      expect(File).not_to exist(File.join(@kit, "lib/gpccmp_test_kit/igs/#{old_version}.tgz"))
      expect(File).not_to exist(File.join(@kit, "lib/gpccmp_test_kit/generated/v#{old_version}"))
      expect(File).to exist(File.join(@kit, "lib/gpccmp_test_kit/igs/#{new_version}.tgz"))
    end
  end

  it 'fails and leaves the kit alone when config.json does not name the previous version' do
    output, status = switch('1.2.3-not-there', new_version)

    expect(status).not_to be_success
    expect(output).to include('1.2.3-not-there')
    expect(kit_file('config.json')).to eq(File.read(File.join(root, 'config.json')))
    expect(File).to exist(File.join(@kit, "lib/gpccmp_test_kit/igs/#{old_version}.tgz"))
  end
end
