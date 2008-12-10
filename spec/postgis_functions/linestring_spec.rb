require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "LineString" do

  before(:all) do
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
  end
   
  it "should sort by size" do
    Street.by_size.first.data.should == "Street1"
    Street.by_size.last.data.should == "Street3"
  end

  it "largest" do
    Street.longest.data.should == "Street3"
  end

  describe "Length" do
    
    it do
      @s1.length.should be_close(1.4142135623731, 0.000001)
    end

    it do
      @s2.length.should be_close(4.2, 0.1)
    end

    it do
      @s3.length.should be_close(42.4264068, 0.001)
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
  end

  it "should not cross s2" do
    @s1.crosses?(@s2).should be_false
  end

  it "should cross s3" do
    @s4.crosses?(@s3).should be_true
  end

  it do
    @s1.touches?(@s2).should be_false
  end

  it do
    @s4.touches?(@s3).should be_false
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
      @s1.centroid.srid.should eql(123)
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

    it do
      @s1.should_not be_envelopes_intersect(@s2)
    end


    it do
      @s1.boundary.should be_instance_of(MultiPoint)
    end
      
  end

  describe "Distance" do
    
    it do
      @s1.distance_to(@p3).should be_close(8.48528137423857,0.0001)
    end

    it do
      lambda { @p1.distance_spheroid_to(@c3) }.should raise_error
    end

    it do
      lambda { @p3.distance_spheroid_to(@s1) }.should raise_error
    end

    it do
      @s1.distance_to(@p3).should be_close(8.48,0.01)
    end
  
  

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
    @s1.should be_simple #?.should be_true
  end

  it  do
    @s1.disjoint?(@s2).should be_true
  end

  it do
    @s1.polygonize.should be_instance_of(GeometryCollection)
  end

  it do
    @s3.polygonize.geometries.should be_empty
  end
  
  it do
    @s2.locate_along_measure(1.6).should be_nil
  end
  
  it do
    @s2.locate_between_measures(0.1,0.3).should be_nil
  end
  
  it "should build area" do
    @s2.build_area.should be_nil
  end
    
end