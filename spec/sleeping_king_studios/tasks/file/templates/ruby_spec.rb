# spec/sleeping_king_studios/tasks/file/templates/ruby_spec.rb

require 'erubis'

RSpec.describe 'file/templates/ruby.erb' do
  let(:locals) do
    {
      :file_path     => 'lib/ichi.rb',
      :file_name     => 'ichi',
      :relative_path => []
    } # end locals
  end # let
  let(:template) do
    File.read 'lib/sleeping_king_studios/tasks/file/templates/ruby.erb'
  end # let
  let(:rendered) do
    Erubis::Eruby.new(template).result(locals)
  end # let
  let(:raw) do
    <<-RUBY
      module Ichi

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
    let(:locals) { super().merge :superclass => 'Ni::San' }
    let(:raw) do
      <<-RUBY
        class Ichi < Ni::San

        end
      RUBY
    end # let

    it { expect(rendered).to be == expected }
  end # describe

  describe 'with a relative path' do
    let(:locals) do
      super().merge(
        :file_path     => 'lib/ichi/ni/san.rb',
        :file_name     => 'san',
        :relative_path => %w(ichi ni)
      ) # end locals
    end # let
    let(:raw) do
      <<-RUBY
        require 'ichi/ni'

        module Ichi::Ni
          module San

          end
        end
      RUBY
    end # let

    it { expect(rendered).to be == expected }

    describe 'with a superclass' do
      let(:locals) { super().merge :superclass => 'Yon::Go' }
      let(:raw) do
        <<-RUBY
          require 'ichi/ni'

          module Ichi::Ni
            class San < Yon::Go

            end
          end
        RUBY
      end # let

      it { expect(rendered).to be == expected }
    end # describe
  end # describe
end # describe
