Postgis Adapter
===============

*Spatial Adapter by Guilhem Vellut*:
A plugin for ActiveRecord which manages the PostGIS geometric columns
in a transparent way (that is like the other base data type columns).
It also provides a way to manage these columns in migrations.

*this* = Spatial Adapter *+* PostGIS Functions *-* MySQL

*PostGIS and Rails 2+ only*.


### Dependencies

- georuby
- postgres


### Installation

On Rails:

    script/plugin install git://github.com/nofxx/postgis_adapter.git

If you are using Spatial Adapter, *remove it first*.

ActiveRecord
------------

Geometric columns in your ActiveRecord models now appear just like
any other column of other basic data types. They can also be dumped
in ruby schema mode and loaded in migrations the same way as columns
of basic types.


### Model

    class TablePoint < ActiveRecord::Base
    end

That was easy! As you see, there is no need to declare a column
as geometric. The plugin will get this information by itself.


### Access

Here is an example of PostGIS row creation and access, using the
model and the table defined above :

  	pt = TablePoint.new(:data => "Hello!",:geom => Point.from_x_y_z(-1.6,2.8,-3.4,123))
  	pt.save
  	pt = TablePoint.find_first
  	puts pt.geom.x #access the geom column like any other


PostGIS Extra Functions
-----------------------

To be documented, here are the cool stuff postgis only let you do:

### How to Use

    class Park < ActiveRecord::Base
      acts_as_geom :area
    end

    ...


    @point  =   Poi.new(    :geom =>   **Point**      )
    @park   =   Park.new(   :geom =>  **Polygon**     )
    @street =   Street.new( :geom => **LineString**   )


### And your objects can do:

    @point.inside?(@park)
    => true
    @point.in_bounds?(@park, 0.5) # margin
    => true

And back:

    @point.outside?(@park)
    => false

Play with polygons:

    @park.area
    => 1345

    @park.contains?(@point)
    => true

And LineStrings:

    @street_east.intersects?(@street_west)
    => false
    @street_central.length
    => 45.53636


### And for classes:

    City.close_to(@point)
    => [Array of cities in order by distance...

    Street.close_to(@point)
    => [Array streets in order by distance...

    Country.contain(@point)
    => The Conutry that contains the point

    Areas.contains(@point)
    => [Array of areas contains the point...


### Find_by

find_by_*column* has been redefined when column is of a geometric type.
Instead of using the Rails default '=' operator, for which I can't see
a definition for MySql spatial datatypes and which performs a bounding
box equality test in PostGIS, it uses a bounding box intersection:
&& in PostGIS and MBRIntersects in MySQL, which can both make use
of a spatial index if one is present to speed up the queries.
You could use this query, for example, if you need to display data
from the database: You would want only the geometries which are in
the screen rectangle and you could use a bounding box query for that.
Since this is a common case, it is the default. You have 2 ways to use
the find_by_*geom_column*: Either by passing a geometric object directly,
or passing an array with the 2 opposite corners of a bounding box
(with 2 or 3 coordinates depending of the dimension of the data).

  	Park.find_by_geom(LineString.from_coordinates([[1.4,5.6],[2.7,8.9],[1.6,5.6]]))

  or

  	Park.find_by_geom([[3,5.6],[19.98,5.9]])

In PostGIS, since you can only use operations with geometries with the same SRID, you can add a third element representing the SRID of the bounding box to the array. It is by default set to -1:

  	Park.find_by_geom([[3,5.6],[19.98,5.9],123])


Database Tools
--------------

### Migrations


Here is an example of code for the creation of a table with a
geometric column in PostGIS, along with the addition of a spatial
index on the column :

    ActiveRecord::Schema.define do
  	  create_table "table_points", :force => true do |t|
        t.string :name
      	t.point  :geom, :srid => 123, :with_z => true, :null => false
    	end
  	  add_index :table_points, :geom, :spatial=>true
    end


### Fixtures

If you use fixtures for your unit tests, at some point,
you will want to input a geometry. You could transform your
geometries to a form suitable for YAML yourself everytime but
the spatial adapter provides a method to do it for you: +to_yaml+.
It works for both MySQL and PostGIS (although the string returned
is different for each database). You would use it like this, if
the geometric column is a point:

    fixture:
  	  id: 1
  	  data: HELLO
  	  geom: <%= Point.from_x_y(123.5,321.9).to_yaml %>


Geometric data types
--------------------

Ruby geometric datatypes are currently made available only through
the GeoRuby library (http://georuby.rubyforge.org): This is where the
*Point.from_x_y* in the example above comes from. It is a goal
of a future release of the Spatial Adapter to support additional
geometric datatype libraries, such as Ruby/GEOS, as long as they
can support reading and writing of EWKB.


Warning
-------

- Since ActiveRecord seems to keep only the string values directly
returned from the database, it translates from these to the correct
types everytime an attribute is read, which is probably ok for simple
types, but might be less than efficient for geometries, since the EWKB
string has to be parsed everytime. Also it means you cannot modify the
geometry object returned from an attribute directly :

       place = Place.first
       place.the_geom.y=123456.7

- Since the translation to a geometry is performed everytime the_geom
is read, the change to y will not be saved! You would have to do
something like this :

       place = Place.first
       the_geom = place.the_geom
       the_geom.y=123456.7
       place.the_geom = the_geom


Project
-------

http://nofxx.lighthouseapp.com/projects/20712-postgis_adapter

### TODO

- Support of other geometric datatype libraries in addition to GeoRuby
- Tutorials

License
-------

Spatial Adapter for Rails is released under the MIT license.
PostGis Adapter is released under the MIT license.


Support
-------

Tested with postgresql 8.3.5 / postgis 1.3.3

Any questions, enhancement proposals, bug notifications or
corrections can be sent to:

### PostGis Adapter

http://nofxx.lighthouseapp.com/projects/20712-postgis_adapter

### SpatialAdapter

guilhem.vellut+georuby@gmail.com.
