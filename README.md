# whatfood

> **⚠️ This project is deprecated.** The AWS backend has been torn down and is no longer operational. All API endpoints, authentication, and storage services are non-functional.

## ⚠️ Important: Cleaning Git History Before Making This Repo Public

Sensitive values (AWS account IDs, API endpoints, credentials, OAuth client IDs) were previously committed to this repository. Although these values have been redacted or removed in the latest commit, **they are still visible in past commits**.

Before making this repository public you **must** scrub the git history using one of the following approaches:

1. **Recommended — create a clean copy without history:**
   ```bash
   # From a fresh clone of this repo (after merging this PR):
   rm -rf .git
   git init
   git add .
   git commit -m "Initial commit (clean)"
   git remote add origin <new-or-existing-repo-url>
   git push --force origin main
   ```

2. **Alternative — use [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/) or `git filter-repo`:**
   ```bash
   # Example with git filter-repo:
   pip install git-filter-repo
   git filter-repo --replace-text expressions.txt
   ```

Without one of these steps, the original secrets remain accessible in the git history.

## Getting Started

