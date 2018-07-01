jekyll build
git add .
gco "Update"
git push
git subtree push --prefix "_site" origin gh-pages
