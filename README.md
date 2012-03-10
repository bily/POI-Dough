# POI Dough

POI Dough is a new way to show off Places of Interest (POI) by importing them from OpenStreetMap and styling them with HTML5 Canvas and CSS3.
Each Place will be connected to a record on MongoDB (through POI Dough) or CouchDB (through DataCouch).

Here are some visual effects available today:
<ul>
<li>Build on top of the best OpenStreetMap and MapBox map tiles</li>
<li>Explore and interact with the beautiful Leaflet.js maps API</li>
<li>Make buildings pop out of the map with a 3D effect</li>
<li>Texture parks, farms, forests, and other areas with your own icons.</li>
<li>Tie appearance of buildings and polygons to tags within OpenStreetMap</li>
</ul>

3D Building with Roof, on MapQuest Open Tiles

<img src="http://i.imgur.com/Bb9Ed.png"/>

## Old Model
The author uses the wealth of OpenStreetMap data as a background, then builds their own layer from scratch.
Participation by users is difficult to build into the system.

<img src="http://i.imgur.com/FOwFW.png"/>

## New Model
The author imports buildings, parks, and other places from OpenStreetMap to populate their map.
Users are invited to interact with the data available at each Place.
Authors can import a dataset from DataCouch to populate their map.

<img src="http://i.imgur.com/5aQ9p.png"/>

# Setup

    git clone git://github.com/mapmeld/POI-Dough.git
    cd POI-Dough
    gem install bundle
    bundle

## Run the tests

    bundle exec rake

## Run the app and background worker

    gem install foreman
    foreman start

You can now open the app in your browser http://localhost:3000

## Running on Heroku

Running this on Heroku requires the following steps:

### Step 1: Create the app on the Heroku Cedar stack

    gem install heroku
    heroku apps:create app_name --stack cedar

We also need to configure it to run in production

    heroku config:add RACK_ENV=production

### Step 2: Add a MongoDB Addon

The MongoHQ or MongoLab Addons will give us a small free MongoDB instance for storing our documents.

    heroku addons:add mongohq:free

### Step 3: Deploy to Heroku

    git push heroku master
    heroku open

When it is finished deploying it will give you the url to your app. Visit in the browser and enjoy!

## License

Open source under the Free BSD licence
Code for America

---

POI Dough is based on Heroku's MongoDB example, which has the following license:
Copyright (c) 2011 Jonathan Hoyt
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
