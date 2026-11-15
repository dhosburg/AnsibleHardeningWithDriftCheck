cd ../lab1-openscap
for f in results-baseline.xml results-after.xml; do
   echo "== $f"
   grep -oE '<(xccdf:)?result>[a-z]+</(xccdf:)?result>' "$f" \
     | grep -oE '>[a-z]+<' | tr -d '><' | sort | uniq -c | sort -rn
done
