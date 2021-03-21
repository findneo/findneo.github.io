cp themes/next2/_config.yml ./_config.next2.yml.bak
hexo clean
hexo d -g
hexo clean
git add -A
if [ "$1" = "" ]
then
git commit -m "Update."
else
git commit -m "$1"
fi
git push origin backup
