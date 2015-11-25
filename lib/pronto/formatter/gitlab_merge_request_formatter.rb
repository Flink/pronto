module Pronto
  module Formatter
    class GitlabMergeRequestFormatter
      def format(messages, repo, patches)
        client = Gitlab.new(repo)
        head = repo.head_commit_sha

        commit_messages = messages.uniq.map do |message|
          commit_line = message.line.commit_line
          STDERR.puts "#{message.commit_sha}, #{message.msg}, #{message.path}, #{commit_line.new_lineno}, #{commit_line.diff_old_lineno}, #{Digest::SHA1.hexdigest(message.path)}"
        end
        "#{commit_messages.compact.count} Pronto messages posted to GitLab"
      end

      private

      def create_comment(client, sha, body, path, position)
        comment = Github::Comment.new(sha, body, path, position)
        comments = client.pull_comments(sha)
        existing = comments.any? { |c| comment == c }
        client.create_pull_comment(comment) unless existing
      rescue Octokit::UnprocessableEntity => e
        # The diff output of the local git version and Github is not always
        # consistent, especially in areas where file renames happened, Github
        # tends to recognize these better, leading to messages we can't post
        # because their diff position is non-existent on Github.
        # Ignore such occasions and continue posting other messages.
        STDERR.puts "Failed to post: #{comment.inspect} with #{e.message}"
      end
    end
  end
end
