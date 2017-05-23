# spec/sleeping_king_studios/tasks/file/templates/rspec_spec.rb

require 'erubi'

RSpec.describe 'file/templates/ruby.erb' do
  let(:locals) do
    {
      :file_path     => 'spec/ichi_spec.rb',
      :file_name     => 'ichi_spec',
      :relative_path => []
    } # end locals
  end # let
  let(:template) do
    File.read 'lib/sleeping_king_studios/tasks/file/templates/rspec.erb'
  end # let
  let(:rendered) do
    source  = Erubi::Engine.new(template).src
    binding = tools.hash.generate_binding(locals)

    binding.eval(source)
  end # let
  let(:raw) do
    <<-RUBY
      require 'ichi'

      RSpec.describe Ichi do
        pending
      end
    RUBY
  end # let
  let(:expected) do
    offset = raw.match(/\A( +)/)[1].length

    tools.string.map_lines(raw) { |line| line[offset..-1] || "\n" }
  end # let

  def tools
    SleepingKingStudios::Tools::Toolbelt.instance
  end # method tools

  it { expect(rendered).to be == expected }

  describe 'with a superclass' do
    let(:locals) do
      super().merge(
        :file_path     => 'spec/ichi/ni/san_spec.rb',
        :file_name     => 'san_spec',
        :relative_path => %w(ichi ni)
      ) # end locals
    end # let
    let(:raw) do
      <<-RUBY
        require 'ichi/ni/san'

        RSpec.describe Ichi::Ni::San do
          pending
        end
      RUBY
    end # let

    it { expect(rendered).to be == expected }
  end # describe
end # describe
