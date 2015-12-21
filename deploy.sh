#!/bin/bash

echo -e "\033[32m [AUTO DEPLOY] deploy hexo start \033[0m"
echo -e "\033[32m [AUTO DEPLOY] hexo generate...  \033[0m"
hexo g
echo -e "\033[32m [AUTO DEPLOY] git commit...  \033[0m"
d=`date +%x-%T`
git add .
git commit -am "auto deploy at "${d}
echo -e "\033[32m [AUTO DEPLOY] git push...  \033[0m"
git push origin master
echo -e "\033[32m [AUTO DEPLOY] deploy hexo finish \033[0m"
