bundle exec rspec
git push origin "$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)"
bundle exec cap production deploy