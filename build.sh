rm -rf output
mkdir output
cp -r public/images output/
cp -r public/stylesheets output/
cp -r public/javascripts output/

wget http://localhost:9393 -q -O output/index.html
wget http://localhost:9393/main.js -q -O output/javascripts/main.js
sed -ie "s/\/main.js/javascripts\/main.js/" output/index.html
cp public/server.rb output/server.rb
cd output && ruby server.rb