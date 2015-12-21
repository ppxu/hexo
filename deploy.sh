#!/bin/bash

echo "start deploy hexo..."
echo "hexo generate..."
hexo g
echo "git commit..."
d=`date +%x-%T`
git add .
git commit -am "auto deploy at "${d}
echo "git push..."
git push origin master
