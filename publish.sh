#!/bin/zsh
# Publish Farm Basket post media to GitHub Pages (farmbasketlv/media).
# First run creates the public repo and turns on Pages; later runs push new/changed files.
set -e
cd "$(dirname "$0")"
export GH_TOKEN=$(gh auth token --user farmbasketlv)
NAME=farmbasketlv; MAIL=farmbasketlv@users.noreply.github.com
if ! gh repo view farmbasketlv/media >/dev/null 2>&1; then
  gh repo create farmbasketlv/media --public --description "Farm Basket social media files (Buffer hosting)"
fi
[ -d .git ] || git init -q -b main
git add -A
git -c user.name=$NAME -c user.email=$MAIL commit -qm "Update media $(date +%F)" || echo "nothing new to commit"
git -c credential.helper= -c "credential.helper=!f(){ echo username=$NAME; echo password=\$GH_TOKEN; };f" \
  push -q https://github.com/farmbasketlv/media.git main
gh api repos/farmbasketlv/media/pages >/dev/null 2>&1 || \
  gh api -X POST repos/farmbasketlv/media/pages -f 'source[branch]=main' -f 'source[path]=/' >/dev/null
echo "Published: https://farmbasketlv.github.io/media/  (first deploy takes ~1 minute)"
