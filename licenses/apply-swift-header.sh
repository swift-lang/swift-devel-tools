
# Append header to file without header, adding first edit date based on history.
# Edit this script to your needs

while read f
do
  date=$(git log --follow --format="%ad" -- $f |
         tail -n1 | grep -o '20[01][0-9]')
  echo $f $date
  if [ "$date" != "" ]
  then
    cat Swift-cog-java-header.txt $f > ${f}.tmp
    sed -i "s/__YEARS__/$date-2014/" ${f}.tmp
    mv ${f}.tmp ${f}
  fi
done
