# frozen_string_literal: true

require 'stringio'
require 'forwardable'

module DiverDown
  class Web
    class IndentedStringIo
      extend ::Forwardable

      def_delegators :@io, :rewind, :string

      attr_accessor :indent

      # @param tab [String]
      def initialize(tab: '  ')
        @io = StringIO.new
        @indent = 0
        @tab = tab
      end

      # @param contents [Array<String>]
      # @param indent [Boolean] Enable or disable indentation
      # @return [void]
      def write(*contents, indent: true)
        indent_string = if indent
                          @tab * @indent
                        else
                          ''
                        end

        string = contents.join
        lines = string.lines
        lines.each do |line|
          if line == "\n"
            @io.write "\n"
          else
            @io.write "#{indent_string}#{line}"
          end
        end
      end

      # @param content [String]
      # @return [void]
      def puts(*contents, indent: true)
        write("#{contents.join("\n")}\n", indent:)
        nil
      end

      # increase the indent level for the block
      def indented
        @indent += 1
        yield
      ensure
        @indent -= 1
      end
    end
  end
end
