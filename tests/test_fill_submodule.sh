# Test fill_submodule function
current_wd=$PWD

rm_mkdir tmp_repos
cd tmp_repos
mkdir project
(cd project && git init &&
    echo "Interesting!" > README.txt &&
    git add README.txt &&
    local_author &&
    git commit -m "first project" &&
    git tag first-commit)
mkdir superproject
cd superproject
git init
git submodule add ../project
local_author
git commit -m "first superproject"
# Check the submodule is working correctly before intervention
cd project
remote_url=$(git config --get remote.origin.url)
[ "$(git log --format="%s")" == "first project" ] || ingest "bad submodule"
[ -f .git ] || ingest "expecting .git to be a file"
cd ..
# Intervene
fill_submodule project
cd project
[ "$(git log --format="%s")" == "first project" ] || ingest "bad after filling"
[ -d .git ] || ingest "expecting .git to be a directory"
[ "$(git config --get remote.origin.url)" == "$remote_url" ] || ingest "bad remote"
# Check we can do a checkout of a branch
git checkout master
# Checkout a tag
git checkout first-commit
cd ..
# Intervene again (has .git directory now)
fill_submodule project
cd project
[ "$(git log --format="%s")" == "first project" ] || ingest "bad after refilling"
[ -d .git ] || ingest "expecting .git to be a directory"
[ "$(git config --get remote.origin.url)" == "$remote_url" ] || ingest "bad remote"
cd ..

cd "$current_wd"
rm -rf tmp_repos
