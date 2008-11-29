require File.dirname(__FILE__) + '/spec_helper.rb'

describe "PostgisFunctions" do
  before(:all) do

    class City < ActiveRecord::Base
      include PolygonFunctions
      has_polygon :geom
    end

    class Position < ActiveRecord::Base
      include PointFunctions
      has_point :geom
    end

    class Street < ActiveRecord::Base
      include LineStringFunctions
      has_line_string :geom
    end

    class CommonGeo < ActiveRecord::Base
    end

    @c1 ||= City.create!(:data => "City1", :geom => Polygon.from_coordinates([[[12,45],[45,41],[4,1],[12,45]],[[2,5],[5,1],[14,1],[2,5]]],123))
    @c2 ||= City.create!(:data => "City1", :geom => Polygon.from_coordinates([[[22,66],[65,65],[20,10],[22,66]],[[10,15],[15,11],[34,14],[10,15]]],123))
    @c3 ||= City.create!(:data => "City3", :geom => Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],123))
    @s1 ||= Street.create!(:data => "Street1", :geom => LineString.from_coordinates([[1,1],[2,2]],123))
    @s2 ||= Street.create!(:data => "Street2", :geom => LineString.from_coordinates([[4,4],[7,7]],123))
    @s3 ||= Street.create!(:data => "Street3", :geom => LineString.from_coordinates([[8,8],[18,18]],123))
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

    it "distance to a linestring" do
      @p1.distance_to(@s2).should be_close(4.24264068711928, 0.0001)
    end

    it "distance to a linestring" do
      @p1.distance_to(@s3).should be_close(9.89949493661167, 0.0001)
    end

    it "distance to a linestring" do
      @p2.distance_to(@s3).should be_close(4.24264068711928, 0.0001)
    end

    it "distance to another point" do
      @p1.distance_to(@p2).should be_close(5.65685424949238, 0.0001)
    end

    it "distance to a polygon" do
      @p1.distance_to(@c2).should be_close(21.0237960416286, 0.0001)
    end

    it "should select the spherical distance" do
     @p1.spherical_distance(@p2).should be_close(628516.874554178, 0.0001)
    end

    it "inside city?" do
      @p1.inside?(@c1).should be_false
    end

    it "ouside city?" do
      @p1.outside?(@c1).should be_true
    end

    it "in bounds of a geometry?" do
      @p1.in_bounds?(@s1).should be_true
    end

    it "in bounds of a geometry? with option" do
      @p3.in_bounds?(@s1, 1).should be_false
    end

    it "calculate another point azimuth??" do
      @p1.azimuth(@p2).should be_close(0.785398163397448,0.000001)
    end

    it "calculate linestring azimuth??" do
    pending
      lambda{ @p1.azimuth(@s2) }.should_raise "Err"
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

    it "its length" do
      @s1.length.should be_close(1.4142135623731, 0.000001)
    end

    it "crosses ?" do
      @s1.crosses?(@s2).should be_false
    end

    it "crosses 2?" do
      @s4.crosses?(@s3).should be_true
    end

    it "touches ?" do
      @s1.touches?(@s2).should be_false
    end

    it "touches 2?" do
      @s4.touches?(@s3).should be_false
    end

    it "should check for crosses" do
      @s4.intersects?(@s3).should be_true
    end

    it "should get a polygon for envelope" do
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

    it "distance to a point" do
      @s1.distance_to(@p3).should be_close(8.48528137423857,0.0001)
    end

    it "number of points" do
      @s3.num_points.should eql(2)
    end

    it "startpoint" do
      @s3.start_point.should be_instance_of(Point)
      @s3.start_point.x.should be_close(8.0, 0.1)
    end

    it "endpoint" do
      @s2.end_point.should be_instance_of(Point)
      @s2.end_point.x.should be_close(7.0, 0.1)
    end

  end


  describe "Polygon" do

    it "sort by area size" do
      City.by_size.first.data.should == "City1" #[@c1, @c2, @c3]
    end

    it "total area" do
      @c3.area.should be_close(1093.270089, 0.1)
    end

    it "total area 2" do
      @c2.area.should be_close(1159.5, 0.1)
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

    it "calculate spatially equality" do
      @c1.spatially_equal?(@c2).should be_false
    end

    it "find all cities that contains a point" do
      City.contains(@p1.geom, 123).should eql([])
    end

    it "should find one city (first) that contains a point" do
      City.contain(@p4.geom, 123).data.should eql("City1")
    end

    it "city covers point?" do
      @c1.covers?(@p1).should be_false
    end

    it "city covers point?" do
      @c1.covers?(@p4).should be_true
    end

    it "city within point?" do
      @c1.within?(@c2).should be_false
    end

    it "city overlaps point?" do
      pending
      @c1.overlaps?(@c2).should be_true
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

  end

end
