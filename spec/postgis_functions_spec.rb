require File.dirname(__FILE__) + '/spec_helper.rb'

describe "PostgisFunctions" do
  before(:all) do
    class Area < ActiveRecord::Base
      include PolygonFunctions
      has_area :geom
    end

    class Position < ActiveRecord::Base
      include PointFunctions
      has_point :geom
    end

    class Route < ActiveRecord::Base
      include LineStringFunctions
      has_line_string :geom
    end

    @a1 ||= Area.create!(:data => "Area1", :geom => Polygon.from_coordinates([[[12,45],[45,41],[4,1],[12,45]],[[2,5],[5,1],[14,1],[2,5]]],123))
    @a2 ||= Area.create!(:data => "Area1", :geom => Polygon.from_coordinates([[[22,66],[65,65],[20,10],[22,66]],[[10,15],[15,11],[34,14],[10,15]]],123))
    @a3 ||= Area.create!(:data => "Area3", :geom => Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],123))
    @r1 ||= Route.create!(:data => "Route1", :geom => LineString.from_coordinates([[1,1],[2,2]],123))
    @r2 ||= Route.create!(:data => "Route2", :geom => LineString.from_coordinates([[4,4],[7,7]],123))
    @r3 ||= Route.create!(:data => "Route3", :geom => LineString.from_coordinates([[8,8],[18,18]],123))
    @p1 ||= Position.create!(:data => "Point1", :geom => Point.from_x_y(1,1,123))
    @p2 ||= Position.create!(:data => "Point2", :geom => Point.from_x_y(5,5,123))
    @p3 ||= Position.create!(:data => "Point3", :geom => Point.from_x_y(8,8,123))

  end


  describe "Point" do

    it "should find the closest other point" do
      Position.close_to(@p1,123).data.should == @p1.data
    end

    it "distance to a linestring" do
      @p1.distance_to(@r2).should be_close(4.24264068711928, 0.0001)
    end

    it "distance to another point" do
      @p1.distance_to(@p2).should be_close(5.65685424949238, 0.0001)
    end

    it "distance to a polygon" do
      @p1.distance_to(@a2).should be_close(21.0237960416286, 0.0001)
    end

    it "should select the spherical distance" do
     @p1.spherical_distance(@p2).should be_close(628516.874554178, 0.0001)
    end

    it "inside area?" do
      @p1.inside?(@a1).should be_false
    end

    it "ouside area?" do
      @p1.outside?(@a1).should be_true
    end

    it "in bounds of a geometry?" do
      @p1.in_bounds?(@r1).should be_true
    end

    it "in bounds of a geometry? with option" do
      @p3.in_bounds?(@r1, 1).should be_false
    end

  end


  describe "LineString" do

    it "should sort by size" do
      Route.by_size.first.data.should == "Route1"
      Route.by_size.last.data.should == "Route3"
    end

    it "largest" do
      Route.longest.data.should == "Route3"
    end

    it "its length" do
      @r1.length.should be_close(1.4142135623731, 0.000001)
    end

    it "crosses ?" do
      @r1.crosses?(@r2).should be_false
    end

    it "should check for crosses" do
      @r4 ||= Route.create!(:data => "Route3", :geom => LineString.from_coordinates([[10,8],[15,18]],123))
      @r4.intersects?(@r3).should be_true
    end

    it "should get a polygon for envelope" do
      @r1.envelope.should be_instance_of(Polygon)
    end

    it "should get a polygon for envelope" do
      @r1.envelope.rings[0].points[0].should be_instance_of(Point)
    end

  end


  describe "Polygon" do

    it "sort by area size" do
      Area.by_size.first.data.should == "Area1" #[@a1, @a2, @a3]
    end

    it "total area" do
      @a3.area.should be_close(1093.270089, 0.1)
    end

    it "total area 2" do
      @a2.area.should be_close(1159.5, 0.1)
    end

    it "contains points?" do
      @a1.contains?(@p1).should be_false
    end

    it "contains created point?" do
      @p4 ||= Position.create!(:data => "Point4", :geom => Point.from_x_y(30,30,123))
      @a1.contains?(@p4).should be_true
    end

    it "calculate spatially equality" do
      @a1.spatially_equal?(@a2).should be_false
    end

    it "find all areas that contains a point" do
      Area.contains(@p1.geom, 123).should eql([])
    end

    it "area covers point?" do
      @a1.covers?(@p1).should be_false
    end

  end

end
