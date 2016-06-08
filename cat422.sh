cd .git/modules/CAT422
echo "Enabling sparse checkout in $PWD"
sed -i '/\[remote\ \"origin\"\]/i \
\tignorecase = true \
\tsparsecheckout = true' config

cd info
echo "Configuring sparse checkout in $PWD"
echo 'locations/*.json
!locations/*.callback.json' > sparse-checkout

cd ../../../../CAT422
echo "Updating tree in $PWD"
git checkout HEAD

echo "CAT422 configuration completed!"
