# install the git hooks
install_git_hooks:
	git config core.hooksPath .git-hooks

check-tag-name:
	./scripts/check-tag-name.sh

add-tag-name:
	./scripts/add-tag-name.sh