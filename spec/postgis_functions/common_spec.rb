require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Common Functions" do

  before(:all) do
    @poly = Polygon.from_coordinates([[[12,45],[45,41],[4,1],[12,45]],[[2,5],[5,1],[14,1],[2,5]]], 4326)
    @c1 ||= City.create!(:data => "City1", :geom => @poly)
    @c2 ||= City.create!(:data => "City1", :geom => Polygon.from_coordinates([[[22,66],[65,65],[20,10],[22,66]],[[10,15],[15,11],[34,14],[10,15]]],4326))
    @c3 ||= City.create!(:data => "City3", :geom => Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],4326))
    @s1 ||= Street.create!(:data => "Street1", :geom => LineString.from_coordinates([[1,1],[2,2]],4326))
    @s2 ||= Street.create!(:data => "Street2", :geom => LineString.from_coordinates([[4,4],[7,7]],4326))
    @s3 ||= Street.create!(:data => "Street3", :geom => LineString.from_coordinates([[8,8],[18,18],[20,20],[25,25],[30,30],[38,38]],4326))
    @s4 ||= Street.create!(:data => "Street4", :geom => LineString.from_coordinates([[10,8],[15,18]],4326))
    @p1 ||= Position.create!(:data => "Point1", :geom => Point.from_x_y(1,1,4326))
    @p2 ||= Position.create!(:data => "Point2", :geom => Point.from_x_y(5,5,4326))
    @p3 ||= Position.create!(:data => "Point3", :geom => Point.from_x_y(8,8,4326))
    @p4 ||= Position.create!(:data => "Point4", :geom => Point.from_x_y(18.1,18,4326))
    @p5 ||= Position.create!(:data => "Point5", :geom => Point.from_x_y(30,30,4326))
  end

  describe "Point" do

    it "should find the closest other point" do
      Position.close_to(@p1.geom)[0].data.should == @p1.data
    end

    it "should find the closest other point" do
      Position.closest_to(@p1.geom).data.should == @p1.data
    end

    it { @p1.distance_to(@s2).should be_close(4.24264068711928, 0.0001) }
    it { @p1.distance_to(@s3).should be_close(9.89949493661167, 0.0001) }
    it { @p2.distance_to(@s3).should be_close(4.24264068711928, 0.0001) }
    it { @p1.distance_to(@p2).should be_close(5.65685424949238, 0.0001) }
    it { @p1.distance_to(@c1).should be_close(3.0, 0.0001) }
    it { @p1.distance_to(@c2).should be_close(21.0237960416286, 0.000001) }
    it { @p1.distance_to(@s2).should be_close(4.24264068711928, 0.000001) }
    it { @p1.distance_sphere_to(@p2).should be_close(628516.874554178, 0.0001) }
    it { @p1.distance_sphere_to(@p3).should be_close(1098726.61466584, 0.00001) }
    it { @p1.distance_spheroid_to(@p2).should be_close(627129.50,0.01) }
    it { @p1.distance_spheroid_to(@p2).should be_close(627129.502639041, 0.000001) }
    it { @p1.distance_spheroid_to(@p3).should be_close(1096324.48117672, 0.000001) }

    it "should find the distance from a unsaved point" do
       @p1.distance_to(@p2).should be_close(5.65685424949238,0.001)
       @p1.distance_to(Point.from_x_y(5,5,4326)).should be_close(5.65685424949238,0.001)
    end

    it { @p1.should_not be_inside(@c1) }
    it { @p1.should be_outside(@c1) }
    it { @p1.should be_inside_circle(2.0,2.0,20.0) }
    it { @p1.should_not be_inside_circle(50,50,2) }
    it { @p1.should be_in_bounds(@s1) }
    it { @p3.should_not be_in_bounds(@s1, 1) }
    it { @p4.in_bounds?(@s3, 0.01).should be_false }

    it { @p1.azimuth(@p2).should be_close(0.785398163397448,0.000001) }
    it { @p1.azimuth(@s2).should raise_error }
    it { @p1.disjoint?(@s2).should be_true }
    it { @p3.polygonize.geometries.should be_empty }
    it { @p4.where_on_line(@s3).should be_close(0.335, 0.0001) }
    it { @s3.locate_point(@p4).should be_close(0.335, 0.1)}
    it { @s3.interpolate_point(0.335).x.should be_close(18.05, 0.01) }

    it { @p1.relate?(@s3, "T*T***FF*").should be_false }
    it { @p1.relate?(@s3).should eql("FF0FFF102") }

    it "should transform srid" do
      @p1.geom = @p1.transform(29101)
      @p1.geom.srid.should eql(29101)
    end

    it "should transform non saved srid geoms" do
      pt = Point.from_x_y(11121381.4586196,10161852.0494475, 29101)
      pos = Position.new(:geom => pt)
      pos.transform(4326)
      pos.geom.x.should be_close(1.00000000000005, 0.00001)
      pos.geom.y.should be_close(1.00000000000005, 0.00001)
    end

    it "should see in what fraction of the ls it is" do
      @p1.where_on_line(@s1).should eql(0.0)
    end

    it "should see in what fraction of the ls it is" do
      @p2.where_on_line(@s2).should be_close(0.3333, 0.1)
    end

    it "should have a srid getter" do
      @p1.srid.should eql(29101)
    end

    it "should calculate the UTM srid" do
      @p2.utm_zone.should eql(32731)
    end

    it "should convert to utm zone" do
      lambda { @p2.to_utm! }.should change(@p2, :srid)
    end

    if PG_VERSION >= "8.4.0"
      it "should export as GeoJSON" do
        @p1.as_geo_json.should eql("{\"type\":\"Point\",\"coordinates\":[1,1]}")
      end
    end


   #  it { @p3.x.should be_close(8.0, 0.1) }
   #  it { @p3.y.should be_close(8.0, 0.1) }
   #  it { @p3.z.should be_close(0.0, 0.1) }

  end

  describe "Polygon" do

    it "sort by area size" do
      City.by_area.first.data.should == "City1" #[@c1, @c2, @c3]
    end

    it "find all cities that contains a point" do
      City.contains(@p1.geom, 4326).should eql([])
    end

    it "should find one city (first) that contains a point" do
      City.contain(@p4.geom, 4326).data.should eql("City1")
    end

    it { @c2.should be_closed }
    it { @c2.dimension.should eql(2) }

    it { @c3.area.should be_close(1093.270089, 0.1) }
    it { @c2.area.should be_close(1159.5, 0.1) }
    it { @c2.area(32640).should be_close(5852791139841.2, 0.01) }

    it { @c2.perimeter.should be_close(219.770013855493, 0.1) }
    it { @c2.perimeter(32640).should be_close(23061464.4268903, 0.1) }
    it { @c2.perimeter3d.should be_close(219.770013855493, 0.1) }

    it { @c1.contains?(@p1).should be_false }
    it { @c1.contains?(@p4).should be_true }

    it { @c1.should_not be_spatially_equal(@c2) }

    it { @c1.covers?(@p1).should be_false }
    it { @c1.covers?(@p4).should be_true }
    it { @c1.should_not be_within(@c2) }

    it "city overlaps point?" do
      lambda { @c3.overlaps?(@c2) }.should raise_error # WHY??
    end

    it "should get a polygon for envelope" do
      @c2.envelope.should be_instance_of(Polygon)
    end

    it "should get a polygon for envelope" do
      @c2.envelope.rings[0].points[0].should be_instance_of(Point)
    end

    it "should get the center" do
      @c2.centroid.x.should be_close(36.2945235015093,0.00001)
      @c2.centroid.y.should be_close(48.3211154233146,0.00001)
    end

    it "should get the center with the correct srid" do
      @c1.centroid.srid.should eql(4326)
    end

    it "distance from another" do
      @c1.distance_to(@c3).should eql(0.0)
    end

    it "distance to a linestring" do
      @c1.distance_to(@s1).should be_close(1.8,0.001)
    end

    it "should simplify me" do
      @c3.simplify.should be_instance_of(Polygon)
    end

    it "should simplify me number of points" do
      @c3.simplify[0].length.should eql(4)
    end

    #Strange again.... s2 s3 ... error
    it { @c3.touches?(@s1).should be_false }
    it { @c2.should be_simple }
    it { @c2.disjoint?(@p2).should be_true }
    it { @c3.polygonize.should have(2).geometries }

    it "should acts as jack" do
      @c2.segmentize(0.1).should be_instance_of(Polygon)
    end


    # weird...
    # it  do
    #   @c1.disjoint?(@p2).should be_true
    # end

    it "should check overlaps" do
      @c2.contains?(@c1).should be_false
    end

    it "should check overlaps non saved" do
      @c2.contains?(@poly).should be_false
    end

    it "should find the UTM zone" do
      @c2.utm_zone.should eql(32737)
    end

    if PG_VERSION >= "8.4.0"
      it "should export as GeoJSON" do
        @c1.as_geo_json.should eql("{\"type\":\"Polygon\",\"coordinates\":[[[12,45],[45,41],[4,1],[12,45]],[[2,5],[5,1],[14,1],[2,5]]]}")
      end
    end

  end

  describe "LineString" do

    describe "Length" do
      it { @s1.length.should be_close(1.4142135623731, 0.000001) }
      it { @s2.length.should be_close(4.2, 0.1) }
      it { @s3.length.should be_close(42.4264068, 0.001) }
      it { @s1.length_spheroid.should be_close(156876.1494,0.0001) }
      it { @s1.length_3d.should be_close(1.4142135623731,0.0001) }
    end

    it { @s1.crosses?(@s2).should be_false }
    it { @s4.crosses?(@s3).should be_true }
    it { @s1.touches?(@s2).should be_false }
    it { @s4.touches?(@s3).should be_false }

    if PG_VERSION >= "8.4.0"
      it "should calculate crossing direction" do
        @s4.line_crossing_direction(@s3).should eql("1")
      end
    end

    it "should intersect with linestring" do
      @s4.intersects?(@s3).should be_true
    end

    it "should not intersect with this linestring" do
      @s4.intersects?(@s1).should be_false
    end

    it "intersection with a point" do
      @s1.intersection(@p2).should be_instance_of(GeometryCollection)
    end

    describe "Self" do

      it do
        @s1.envelope.should be_instance_of(Polygon)
      end

      it "should get a polygon for envelope" do
        @s1.envelope.rings[0].points[0].should be_instance_of(Point)
      end

      it "should get the center" do
        @s1.centroid.x.should be_close(1.5,0.01)
        @s1.centroid.y.should be_close(1.5,0.01)
      end

      it "should get the center with the correct srid" do
        @s1.centroid.srid.should eql(4326)
      end

      it "number of points" do
        @s3.num_points.should eql(6)
      end

      it "startpoint" do
        @s3.start_point.should be_instance_of(Point)
        @s3.start_point.x.should be_close(8.0, 0.1)
      end

      it "endpoint" do
        @s2.end_point.should be_instance_of(Point)
        @s2.end_point.x.should be_close(7.0, 0.1)
      end

      it { @s1.should_not be_envelopes_intersect(@s2) }
      it { @s1.boundary.should be_instance_of(MultiPoint) }


      if PG_VERSION >= "8.4.0"
        it "should export as GeoJSON" do
          @s1.as_geo_json.should eql("{\"type\":\"LineString\",\"coordinates\":[[1,1],[2,2]]}")
        end
      end

    end

    describe "Distance" do

      it { @s1.distance_to(@p3).should be_close(8.48528137423857,0.0001) }
      it { @s1.distance_to(@p3).should be_close(8.48,0.01) }

      it do
        lambda { @p1.distance_spheroid_to(@c3) }.should raise_error
      end

      it do
        lambda { @p3.distance_spheroid_to(@s1) }.should raise_error
      end

    end

    it do @s1.locate_point(@p1).should eql(0.0) end
    it do @s1.locate_point(@p2).should eql(1.0) end

    it "should simplify a line" do
      @s3.simplify.points.length.should eql(2)
    end

    it "should simplify the first correcty" do
      @s3.simplify.points[0].y.should be_close(8.0, 0.1)
    end

    it "should simplify the last correcty" do
      @s3.simplify.points[1].y.should be_close(38.0, 0.1)
    end

    it { @s1.overlaps?(@c2).should be_false }
    it { @s1.overlaps?(@s2).should be_false }
    it { @s1.convex_hull.should be_instance_of(LineString) }
    it { @s1.line_substring(0.2,0.5).should be_instance_of(LineString) }

    it do
      @s1.interpolate_point(0.7).should be_instance_of(Point)
      @s1.interpolate_point(0.7).x.should be_close(1.7,0.1)
    end

    it { @s1.should be_simple }
    it { @s1.disjoint?(@s2).should be_true }
    it { @s1.polygonize.should be_instance_of(GeometryCollection) }
    it { @s3.polygonize.geometries.should be_empty }
    it { @s2.locate_along_measure(1.6).should be_nil }
    it { @s2.locate_between_measures(0.1,0.3).should be_nil }

    it "should build area" do
      @s2.build_area.should be_nil
    end

    it "should acts as jack" do
      @s2.segmentize(0.1).should be_instance_of(LineString)
    end

    it "should find the UTM zone" do
      @s2.utm_zone.should eql(32731)
    end

    it "should find the UTM zone" do
      @s2.transform!(29101)
      @s2.utm_zone.should eql(32732)
    end

    it "should transform non saved" do
      ls = LineString.from_coordinates([[11435579.3992231,10669620.8116516],[11721337.4281638,11210714.9524106]],29101)
      str = Street.new(:geom => ls)
      str.transform(4326)
      str.geom[0].x.should be_close(4,0.0000001)
      str.geom[0].y.should be_close(4,0.0000001)
      str.geom[1].x.should be_close(7,0.0000001)
      str.geom[1].y.should be_close(7,0.0000001)
    end
  end

end
