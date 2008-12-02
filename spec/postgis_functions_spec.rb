require File.dirname(__FILE__) + '/spec_helper.rb'

describe "PostgisFunctions" do
  before(:all) do
    #load_schema

    class City < ActiveRecord::Base
      acts_as_geom :geom
    end

    class Position < ActiveRecord::Base
      acts_as_geom :geom
    end

    class Street < ActiveRecord::Base
      acts_as_geom :geom
    end

    class CommonGeo < ActiveRecord::Base
    end

    @c1 ||= City.create!(:data => "City1", :geom => Polygon.from_coordinates([[[12,45],[45,41],[4,1],[12,45]],[[2,5],[5,1],[14,1],[2,5]]],123))
    @c2 ||= City.create!(:data => "City1", :geom => Polygon.from_coordinates([[[22,66],[65,65],[20,10],[22,66]],[[10,15],[15,11],[34,14],[10,15]]],123))
    @c3 ||= City.create!(:data => "City3", :geom => Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],123))
    @s1 ||= Street.create!(:data => "Street1", :geom => LineString.from_coordinates([[1,1],[2,2]],123))
    @s2 ||= Street.create!(:data => "Street2", :geom => LineString.from_coordinates([[4,4],[7,7]],123))
    @s3 ||= Street.create!(:data => "Street3", :geom => LineString.from_coordinates([[8,8],[18,18],[20,20],[25,25],[30,30],[38,38]],123))
    @s4 ||= Street.create!(:data => "Street3", :geom => LineString.from_coordinates([[10,8],[15,18]],123))
    @p1 ||= Position.create!(:data => "Point1", :geom => Point.from_x_y(1,1,123))
    @p2 ||= Position.create!(:data => "Point2", :geom => Point.from_x_y(5,5,123))
    @p3 ||= Position.create!(:data => "Point3", :geom => Point.from_x_y(8,8,123))
    @p4 ||= Position.create!(:data => "Point4", :geom => Point.from_x_y(30,30,123))
  end


  describe "Point" do

    it "should find the closest other point" do
      Position.close_to(@p1.geom,123)[0].data.should == @p1.data
    end

    it "should find the closest other point" do
      Position.closest_to(@p1.geom,123).data.should == @p1.data
    end

    it  do
      @p1.distance_to(@s2).should be_close(4.24264068711928, 0.0001)
    end

    it  do
      @p1.distance_to(@s3).should be_close(9.89949493661167, 0.0001)
    end

    it  do
      @p2.distance_to(@s3).should be_close(4.24264068711928, 0.0001)
    end

    it  do
      @p1.distance_to(@p2).should be_close(5.65685424949238, 0.0001)
    end

    it do
      @p1.distance_sphere_to(@p2).should be_close(628516.874554178, 0.0001)
    end

    it do
      @p1.distance_sphere_to(@p3).should be_close(1098726.61466584, 0.00001)
    end

    it  do
      @p1.distance_to(@c1).should be_close(3.0, 0.0001)
    end

    it  do
      @p1.distance_to(@c2).should be_close(21.0237960416286, 0.000001)
    end

    it  do
      @p1.distance_to(@s2).should be_close(4.24264068711928, 0.000001)
    end

    it  do
      @p1.distance_spheroid_to(@p2).should be_close(627129.45,0.01)
    end

    it do
      @p1.distance_spheroid_to(@p2).should be_close(627129.457699803, 0.000001)
    end

    it do
      @p1.distance_spheroid_to(@p3).should be_close(1096324.40267746, 0.000001)
    end

    it do
      @p1.should_not be_inside(@c1)
    end

    it do
      @p1.should be_outside(@c1)
    end

    it do
      @p1.should be_in_bounds(@s1)
    end

    it "in bounds of a geometry? with option" do
      @p3.should_not be_in_bounds(@s1, 1)
    end

    it "calculate another point azimuth??" do
      @p1.azimuth(@p2).should be_close(0.785398163397448,0.000001)
    end

    it "calculate linestring azimuth??" do
      @p1.azimuth(@s2).should raise_error
    end

    it "should see in what fraction of the ls it is" do
      @p1.where_on_line(@s1).should eql(0.0)
    end

    it do
      @p1.should be_inside_circle(2.0,2.0,20.0)
    end

    it do
      @p1.should_not be_inside_circle(50,50,2)
    end

  end

  describe "LineString" do

    it "should sort by size" do
      Street.by_size.first.data.should == "Street1"
      Street.by_size.last.data.should == "Street3"
    end

    it "largest" do
      Street.longest.data.should == "Street3"
    end

    it do
      @s1.length.should be_close(1.4142135623731, 0.000001)
    end

    it do
      @s2.length.should be_close(4.2, 0.1)
    end

    it do
      @s3.length.should be_close(42.4264068, 0.001)
    end

    it do
      @s1.crosses?(@s2).should_not be_true
    end

    it do
      @s4.crosses?(@s3).should be_true
    end

    it do
      @s1.touches?(@s2).should be_false
    end

    it do
      @s4.touches?(@s3).should be_false
    end

    it do
      @s4.intersects?(@s3).should be_true
    end

    it do
      @s4.intersects?(@s1).should be_false
    end

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
      @s1.centroid.srid.should eql(123)
    end

    it do
      @s1.distance_to(@p3).should be_close(8.48528137423857,0.0001)
    end

    it do
      @p1.distance_spheroid_to(@c3).should raise_error
    end

    it do
      @p3.distance_spheroid_to(@s1).should raise_error
    end

    it do
      @s1.distance_to(@p3).should be_close(8.48,0.01)
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

    it "3d length" do
      @s1.length_3d.should be_close(1.4142135623731,0.0001)
    end

    it do
      @s1.length_spheroid.should be_close(156876.1381,0.0001)
    end

#    it do
#      @s1.length_spheroid.in_miles.should be_close(156.876,0.001)
#    end

    it do
      @s1.should_not be_envelopes_intersect(@s2)
    end

    it do
      @s1.boundary.should be_instance_of(MultiPoint)
    end

    it "intersection with a point" do
      @s1.intersection(@p2).should be_instance_of(GeometryCollection)
    end

    it "should locate a point" do
      @s1.locate_point(@p1).should eql(0.0)
    end

    it "should locate a point" do
      @s1.locate_point(@p2).should eql(1.0)
    end

    it "should simplify a line" do
      @s3.simplify.points.length.should eql(2)
    end

    it "should simplify the first correcty" do
      @s3.simplify.points[0].y.should be_close(8.0, 0.1)
    end

    it "should simplify the last correcty" do
      @s3.simplify.points[1].y.should be_close(38.0, 0.1)
    end

    it do
      @s1.overlaps?(@c2).should be_false
    end

    it do
      @s1.overlaps?(@s2).should be_false
    end

    it do
      @s1.convex_hull.should be_instance_of(LineString)
    end

    it do
      @s1.line_substring(0.2,0.5).should be_instance_of(LineString)
    end

    it do
      @s1.interpolate_point(0.7).should be_instance_of(Point)
      @s1.interpolate_point(0.7).x.should be_close(1.7,0.1)
    end

    it do
      @s1.simple?.should be_true
    end
  end


  describe "Polygon" do

    it "sort by area size" do
      City.by_size.first.data.should == "City1" #[@c1, @c2, @c3]
    end

    it do
      @c2.should be_closed
    end

    it do
      @c3.area.should be_close(1093.270089, 0.1)
    end

    it do
      @c2.area.should be_close(1159.5, 0.1)
    end

    it "dimension x" do
      @c2.dimension.should eql(2)
    end

    it "perimter 2d" do
      @c2.perimeter.should be_close(219.770013855493, 0.1)
    end

    it "perimter 3d" do
      @c2.perimeter3d.should be_close(219.770013855493, 0.1)
    end

    it "contains points?" do
      @c1.contains?(@p1).should be_false
    end

    it "contains created point?" do
      @c1.contains?(@p4).should be_true
    end

    it do
      @c1.should_not be_spatially_equal(@c2)
    end

    it "find all cities that contains a point" do
      City.contains(@p1.geom, 123).should eql([])
    end

    it "should find one city (first) that contains a point" do
      City.contain(@p4.geom, 123).data.should eql("City1")
    end

    it do
      @c1.should_not be_covers(@p1)
    end

    it do
      @c1.should be_covers(@p4)
    end

    it do
      @c1.should_not be_within(@c2)
    end

    it "city overlaps point?" do
      @c3.overlaps?(@c2).should raise_error # WHY??
    end

    it "city disjoint point?" do
      pending
      @c1.disjoint?(@s2).should be_false
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
      @c1.centroid.srid.should eql(123)
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
    it do
      @c3.touches?(@s1).should be_false
    end

    it do
      @c2.should be_simple
    end


  end

  describe "BBox operations" do

    it "should check stricly left" do
      @p1.bbox("<<", @c1).should be_true
    end

    it "should check stricly right" do
      @p1.bbox(">>", @c1).should be_false
    end

    it  do
      @p1.should be_strictly_left_of(@c1)
    end

    it  do
      @p1.should_not be_strictly_right_of(@c1)
    end

    it do
      @p1.should_not be_overlaps_or_right_of(@c1)
    end

    it do
      @p1.should be_overlaps_or_left_of(@c1)
    end

    it do
      @p1.should_not be_completely_contained_by(@c1)
    end

    it  do
      @c2.completely_contains?(@p1).should be_false
    end

    it  do
      @p1.should be_overlaps_or_above(@c1)
    end

    it  do
      @p1.should be_overlaps_or_below(@c1)
    end

    it do
      @p1.should_not be_strictly_above(@c1)
    end

    it do
      @p1.should_not be_strictly_below(@c1)
    end

    it do
      @p1.interacts_with?(@c1).should be_false
    end

    it do
      @p1.binary_equal?(@c1).should be_false
    end

    it do
      @p1.same_as?(@c1).should be_false
    end


  end

  #TODO is sorted rspec helper
  describe "Class methods" do

    it "should find all dwithin one" do
      Position.all_within(@s1.geom).should be_instance_of(Array)
    end

    it "should find all dwithin one" do
      City.by_perimeter.should be_instance_of(Array)
    end

    it "should sort by polygon area" do
      City.by_area.should be_instance_of(Array)
    end

    it "should sort by all within" do
      City.all_within(@s1.geom).should be_instance_of(Array)
    end

    it "should sort by all within" do
      City.by_boundaries.should be_instance_of(Array)
    end

  end

end
