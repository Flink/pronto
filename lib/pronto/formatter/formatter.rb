module Pronto
  module Formatter
    def self.get(name)
      formatter = FORMATTERS[name.to_s] || TextFormatter
      formatter.new
    end

    def self.names
      FORMATTERS.keys
    end

    FORMATTERS = {
      'github' => GithubFormatter,
      'github_pr' => GithubPullRequestFormatter,
      'gitlab' => GitlabFormatter,
      'gitlab_mr' => GitlabMergeRequestFormatter,
      'json' => JsonFormatter,
      'checkstyle' => CheckstyleFormatter,
      'text' => TextFormatter,
      'null' => NullFormatter
    }
  end
end
