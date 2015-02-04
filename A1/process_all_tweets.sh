mkdir -v processed_tweets
for file in /u/cs401/A1/tweets/*; do
	f=`basename $file`
	python twtt.py $file processed_tweets/$f.twt
done
