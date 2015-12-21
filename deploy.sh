#!/bin/bash

echo "\033[32m deploy hexo start \033[0m"
echo "\033[32m hexo generate...  \033[0m"
hexo g
echo "\033[32m git commit...  \033[0m"
d=`date +%x-%T`
git add .
git commit -am "auto deploy at "${d}
echo "\033[32m git push...  \033[0m"
git push origin master
echo "\033[32m deploy hexo finish  \033[0m"
