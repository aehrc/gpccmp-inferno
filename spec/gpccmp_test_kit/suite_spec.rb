# frozen_string_literal: true

require 'json'

# Checks that the kit, as committed, is one consistent whole: config.json, the IG archive,
# the generated suite and the kit's entry point all agree on the same IG version, and the
# suite loads. A regeneration that leaves any of them behind fails here.
RSpec.describe 'the generated GPCCMP suite' do
  root = File.expand_path('../..', __dir__)
  config = JSON.parse(File.read(File.join(root, 'config.json')))
  ig_version = config.dig('ig', 'version')

  def all_groups(runnable)
    runnable.groups.flat_map { |group| [group, *all_groups(group)] }
  end

  let(:suite) do
    require File.join(root, 'lib/gpccmp_test_kit')
    Inferno::Repositories::TestSuites.new.all.find { |s| s.title == "#{config.dig('suite', 'title')} v#{ig_version}" }
  end

  it 'has the IG archive that config.json points at' do
    archive = config.dig('ig', 'package_archive_path')

    expect(File.basename(archive, '.tgz')).to eq(ig_version)
    expect(File).to exist(File.join(root, archive))
  end

  it 'gives the validator the same IG archive' do
    expect(File.basename(config.dig('suite', 'rewrite_igs'), '.tgz')).to eq(ig_version)
  end

  it 'holds exactly one generated suite, the one for the configured IG version' do
    generated = Dir.children(File.join(root, 'lib/gpccmp_test_kit/generated'))

    expect(generated).to eq(["v#{ig_version}"])
  end

  it 'loads through the kit entry point and registers with Inferno' do
    expect(suite).not_to be_nil
  end

  it 'contains a group for every generated group file' do
    group_ids = all_groups(suite).map(&:id)
    group_files = Dir[File.join(root, "lib/gpccmp_test_kit/generated/v#{ig_version}/*_group.rb")]

    expect(group_files).not_to be_empty
    group_files.each do |file|
      expect(group_ids).to include(a_string_ending_with("_#{File.basename(file, '_group.rb')}"))
    end
  end

  it 'contains every outer group named in config.json' do
    group_ids = all_groups(suite).map(&:id)

    config.dig('suite', 'outer_groups').each do |outer_group|
      expect(group_ids).to include(a_string_ending_with(outer_group['group_id']))
    end
  end

  it 'has tests in every leaf group' do
    empty = all_groups(suite).select { |group| group.groups.empty? && group.tests.empty? }

    expect(empty.map(&:id)).to be_empty
  end
end
