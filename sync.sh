#!/bin/bash

echo -e "\033[32m [AUTO SYNC] sync hexo start \033[0m"
cd /ppxu/blog
echo -e "\033[32m [AUTO SYNC] git pull...  \033[0m"
git pull origin master
echo -e "\033[32m [AUTO SYNC] sync hexo finish \033[0m"
