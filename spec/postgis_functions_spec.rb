require File.dirname(__FILE__) + '/spec_helper.rb'

describe "PostgisFunctions" do

    before(:each) do

      class Area < ActiveRecord::Base
        include AreaFunctions
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
      @r1 ||= Route.create!(:data => "Route1", :geom => LineString.from_coordinates([[1,1],[3,3]],123))
      @r2 ||= Route.create!(:data => "Route2", :geom => LineString.from_coordinates([[4,4],[6,6]],123))
      @r3 ||= Route.create!(:data => "Route3", :geom => LineString.from_coordinates([[7,7],[18,18]],123))
      @p1 ||= Position.create!(:data => "Point1", :geom => Point.from_x_y(1,1,123))
      @p2 ||= Position.create!(:data => "Point2", :geom => Point.from_x_y(5,5,123))
      @p3 ||= Position.create!(:data => "Point3", :geom => Point.from_x_y(8,8,123))

    end

    it "should find the closest other point" do
       Position.close_to(@p1,123).data.should == @p1.data
    end

    it "should find all areas ." do
     # Area.within(@a3)
    end

     it "should find all areas ." do
     # Area.contains(@a3)
   #  p Area.connection.columns(Area.connection.tables[5])[1].parent
    end

    it "should find the distance from a linestring" do
      @p1.distance(@r2).should be_close(4.24264068711928, 0.0001)
    end

    it "should find the length of a linestring" do
   # p Position.superclass
     # @a3.contains?(@p1).should be_true
    end

    it "should sort area by size" do
      Area.by_size.first.data.should == "Area1" #[@a1, @a2, @a3]
     # Area.by_size.last.data.should == "Area1"
    end

    it "should calculate the area size" do
      @a1.area.should be_close(724.0, 0.1)
    end

    it "should calculate the area size" do
      @a2.area.should be_close(1159.5, 0.1)
    end

    it "should see if point is in area" do
      @a1.contains?(@p1).should be_false
    end

        it "should sort linestrig by size" do
    #  Route.by_size.first.data.should == "Route1" #[@a1, @a2, @a3]
    #  Route.by_size.last.data.should == "Route3"
    end

    it "should calcula the length" do
      @r1.length.should be_close(2.82842712474619, 0.000001)
    end
end
