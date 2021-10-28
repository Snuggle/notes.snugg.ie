#!/usr/bin/env bash

temporary_directory="/tmp/snugg-ie_temporary_git_clone"

echo "🗑  Removing old blog posts."
#rm -r _posts
rm -r "Blog Posts"
rm -r assets
echo "🔀 Setting up Git directory & sparse checkout."
original_directory="$(pwd)"
mkdir "$temporary_directory"; cd "$temporary_directory"
git init
git remote add origin https://github.com/snuggle/snugg.ie
git config core.sparseCheckout true
echo -en "/_posts\n/assets/images" > .git/info/sparse-checkout
echo "⬇️  Pulling blog posts from Git."
git pull origin master --quiet
echo "✅ Finished pulling blog posts from Git."
echo "🗑  Removing Git directory, it's not needed anymore."
rm -rf .git

echo "🚚 Moving things back into their proper places..."
mv _posts "$original_directory/Blog Posts"
mv assets "$original_directory/assets"
cd "$original_directory"

printf "🗑️  "
rm -rv "$temporary_directory"

echo "ℹ️  Making automated edits to blog posts."
cd "Blog Posts"
for post in *.md
do
	echo "🧹 Un-jekylling: '$post'"

	# Remove all Jekyll 'Liquid' tags
	sed -i -e 's/{.*}//g' "$post"
	# Rename any references to '/assets/' to a relative 'assets/'
	sed -i -e 's/\/assets\//..\/assets\//g' "$post"

	# Fix links to other blog posts #todo: Needs improvement, currently hardcoded.
	sed -i -e 's/(\/posts\/hug-server)/[[Hug Server]]/g' "$post"
	sed -i -e 's/\[.*\]\[\[/\[\[/g' "$post"


	####################
	# Blog Post Naming #

	# 's/^\d{4}-\d{2}-\d{2}-//'
	# Remove date in front of blog post. ('2021-05-09-server-cabinet.md' -> 'server-cabinet.md')
	
	# 's/-/ /g'
	# Remove all dashes in file name. ('server-cabinet.md' -> 'server cabinet.md')
	
	# 's/(^|[\s_-])([a-z])/$1\u$2/g'
	# Convert the filename to Title Case ('server cabinet.md' -> 'Server Cabinet.md')
	printf "🚚 "
	
	if [ "$(uname)" == "Darwin" ]; then
	    # Do something under Mac OS X platform       
	    rename -v -e 's/^\d{4}-\d{2}-\d{2}-//' -e 's/-/ /g' -e 's/(^|[\s_-])([a-z])/$1\u$2/g' "$post" 
	elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
		# Do something under GNU/Linux platform
		rename -v -E 's/^\d{4}-\d{2}-\d{2}-//; s/-/ /g; s/(^|[\s_-])([a-z])/$1\u$2/g' "$post"
		
	fi
done
cd ..
echo "🏁 Done! All blog posts have been updated."
