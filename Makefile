# install the git hooks
install_git_hooks:
	git config core.hooksPath .git-hooks

# Check the tag name is valid or not for the project
check-tag-name:
	./scripts/check-tag-name.sh

# Add a new tag name for the project
add-tag-name:
	./scripts/add-tag-name.sh