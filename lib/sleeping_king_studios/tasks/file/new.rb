# lib/sleeping_king_studios/tasks/file/new.rb

require 'erubi'

require 'fileutils'

require 'sleeping_king_studios/tasks/file'

module SleepingKingStudios::Tasks::File
  # rubocop:disable Metrics/ClassLength

  # Thor task for generating a new Ruby source file.
  class New < SleepingKingStudios::Tasks::Task
    def self.description
      'Creates a Ruby source file and corresponding spec file.'
    end # class method description

    option :'dry-run',
      :aliases => '-d',
      :type    => :boolean,
      :default => false,
      :desc    =>
        'Lists the file(s) to create, but does not change the filesystem.'
    option :force,
      :aliases => '-f',
      :type    => :boolean,
      :default => false,
      :desc    => 'Overwrite the files if the files already exist.'
    option :prompt,
      :aliases => '-p',
      :type    => :boolean,
      :default => false,
      :desc    => 'Prompt the user for confirmation before creating the files.'
    option :quiet,
      :aliases => '-q',
      :type    => :boolean,
      :default => false,
      :desc    => 'Suppress output to STDOUT.'
    option :spec,
      :type    => :boolean,
      :default => true,
      :desc    => 'Create a spec file for the new source file.'
    option :verbose,
      :aliases => '-v',
      :type    => :boolean,
      :default => false,
      :desc    => 'Print additional information about the task.'

    def call file_path
      split_file_path(file_path)

      check_for_existing_file file_path
      check_for_existing_file spec_path if spec?

      preview

      return unless prompt_confirmation

      create_source_file
      create_spec_file

      say 'Complete!', :green
    end # method file_name

    private

    attr_reader :directory
    attr_reader :file_name
    attr_reader :file_path
    attr_reader :relative_path
    attr_reader :spec_path

    alias_method :mute?, :quiet?

    def check_for_existing_file file_path
      return unless File.exist?(file_path)

      raise "file already exists at #{file_path}" unless force?
    end # method check_for_existing_file

    def create_source_file
      create_directories directory, *relative_path

      File.write file_path, rendered_source unless dry_run?
    end # method create_file

    def create_spec_file
      return unless spec?

      return if spec_file?

      create_directories 'spec', *relative_path

      File.write spec_path, rendered_spec unless dry_run?
    end # method create_spec_file

    def create_directories *directory_names
      return if dry_run?

      FileUtils.mkdir_p directory_names.compact.join(File::SEPARATOR)
    end # method create_directories

    def find_template name
      template_paths.each do |template_dir|
        template_path = File.expand_path(File.join template_dir, name)

        next unless File.exist?(template_path)

        return File.read(template_path)
      end # each

      nil
    end # method find_template

    def preview
      say 'Files to create:'
      say "\n"

      preview_files

      say "\n" unless verbose?
    end # method preview

    def preview_file file_path, max:, template:
      str = "  %-#{max}.#{max}s  # using template '%s'"

      say format(str, file_path, template)

      return unless verbose?

      say "\n"
      say yield
      say "\n"
    end # method preview_file

    # rubocop:disable Metrics/AbcSize
    def preview_files
      max = spec? ? [file_path.length, spec_path.length].max : file_path.length

      template = spec_file? ? 'rspec.erb' : 'ruby.erb'

      preview_file file_path, :max => max, :template => template do
        tools.string.indent(rendered_source, 4)
      end # preview_file

      return unless spec? && !spec_file?

      preview_file spec_path, :max => max, :template => 'rspec.erb' do
        tools.string.indent(rendered_spec, 4)
      end # preview_file
    end # method preview_files
    # rubocop:enable Metrics/AbcSize

    def prompt_confirmation
      return true unless prompt?

      unless yes? 'Create files? (yes|no)\n>'
        say "\n"
        say 'Cancelled!', :yellow

        return false
      end # if-else

      say "\n"

      true
    end # prompt_confirmation

    def render_template name, locals = {}
      template = find_template(name)
      source   = Erubi::Engine.new(template).src
      binding  = Object.new.send(:binding)

      locals.each do |key, value|
        binding.local_variable_set key, value
      end # each

      binding.eval source
    end # method render_template

    def rendered_source
      template = spec_file? ? 'rspec.erb' : 'ruby.erb'

      @rendered_source ||=
        render_template(
          template,
          :file_path     => file_path,
          :file_name     => file_name,
          :relative_path => relative_path
        ) # end render template
    end # method rendered_source

    def rendered_spec
      @rendered_spec ||=
        render_template(
          'rspec.erb',
          :file_path     => spec_path,
          :file_name     => "#{file_name}_spec",
          :relative_path => relative_path
        ) # end render template
    end # method rendered_spec

    def spec_file?
      directory == 'spec' && file_name.end_with?('_spec')
    end # method spec_file?

    def split_file_path file_path
      @file_path     = file_path
      @directory     = nil
      extension      = File.extname(file_path)
      fragments      = file_path.split(File::SEPARATOR)
      @file_name     = File.basename(fragments.pop, extension)

      split_relative_path fragments

      @spec_path =
        File.join 'spec', *relative_path, "#{file_name}_spec#{extension}"
    end # method split_file_path

    def split_relative_path fragments
      if %w(app apps lib spec tmp vendor).include?(fragments.first)
        @directory = fragments.shift
      end # if

      @relative_path = fragments
    end # method split_relative_path

    def template_paths
      SleepingKingStudios::Tasks.configuration.file.template_paths
    end # method template_paths

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end # method tools
  end # class

  # rubocop:enable Metrics/ClassLength
end # module
