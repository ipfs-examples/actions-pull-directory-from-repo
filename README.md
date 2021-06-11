# Pull From Another Repository

A Github Action that can pull changes from a directory of a given repository. This action allows to create a fork and go repository based on a directory/folder of another repository.

## Inputs

### `destination-repo`

**Required** Target repository to pull directory.

### `destination-folder-path`

**Required** Target repository path folder to be pulled.

### `destination-branch`

**Required** Target repository branch to pull the irectory. Defaults to `main`

### `source-branch`

**Required** Source repository branch to push the directory. Defaults to `main`

### `git-username`

**Required** Username to be used by git. Defaults to `github-actions`

### `git-email`

**Required** Email to be used by git. Defaults to `github-actions@github.com`

## Usage

```yaml
- name: Pull from another repository
  uses: ipfs-examples/actions-pull-directory-from-repo
  with:
    destination-repo: 'ipfs-examples/examples-source'
    destination-folder-path: 'examples/example1'
    destination-branch: 'main'
    source-branch: 'main'
    git-username: github-actions
    git-email: github-actions@github.com
```

This will pull all given folder/directory and push everything (if has changes) to the current repository using the git configurations provided.
