bundle exec jekyll build
git add .
git commit -am "Update"
git push
git subtree push --prefix "_site" origin gh-pages
