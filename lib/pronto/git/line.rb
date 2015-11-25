module Pronto
  module Git
    Line = Struct.new(:line, :patch, :hunk) do
      extend Forwardable

      def_delegators :line, :addition?, :deletion?, :content, :new_lineno,
                     :old_lineno, :line_origin

      def position
        hunk_index = patch.hunks.find_index { |h| h.header == hunk.header }
        line_index = patch.lines.find_index(line)

        line_index + hunk_index + 1
      end

      def commit_sha
        blame[:final_commit_id] if blame
      end

      def commit_line
        @commit_line ||= begin
          patches = patch.repo.show_commit(commit_sha)

          result = patches.find_line(patch.new_file_full_path,
                                     blame[:orig_start_line_number])
          result || self # no commit_line means that it was just added
        end
      end

      def ==(other)
        return false if other.nil?
        return true if line.nil? && other.line.nil?

        content == other.content &&
          line_origin == other.line_origin &&
          old_lineno == other.old_lineno &&
          new_lineno == other.new_lineno
      end

      def diff_old_lineno
        (previous_line || line).old_lineno + 1
      end

      private

      def blame
        @blame ||= patch.blame(new_lineno)
      end

      def all_lines
        @all_lines ||= hunk.lines
      end

      def previous_line
        @previous_line ||= all_lines[0..(position - 1)]
          .reverse
          .detect { |line| line.old_lineno != -1 }
      end
    end
  end
end
