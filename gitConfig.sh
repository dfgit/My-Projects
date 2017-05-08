# run like this USER_NAME="?" USER_EMAIL="?" GITHUB_USER="?" GITHUB_TOKEN="?" bash < <(curl -s "https://raw.github.com/gist/1415243/9ba97176d660fa86590a3f65d6cedbda1dc41d44/setup_git_config.sh")

git config --global user.name "$USER_NAME"
git config --global user.email "$USER_EMAIL"
git config --global color.branch "auto"
git config --global color.diff "auto"
git config --global color.interactive "auto"
git config --global color.status "auto"
git config --global branch.autosetuprebase "always"
git config --global alias.co "checkout"
git config --global alias.ci "commit"
git config --global alias.st "status"
git config --global alias.lo "log --graph -last:3"
git config --global alias.unstage "reset HEAD --"
git config --global push.default "tracking"
git config --global help.autocorrect "1"
git config --global github.user "$GITHUB_USER"
git config --global github.token "$GITHUB_TOKEN"
git config --global branch.master.mergeoptions "always":
