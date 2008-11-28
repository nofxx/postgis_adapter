require File.dirname(__FILE__) + '/spec_helper.rb'

describe "PostgisFunctions" do

    before(:all) do


      class Area < ActiveRecord::Base
      end

      class Position < ActiveRecord::Base
      end

      class Route < ActiveRecord::Base
      end

      @a1 = Area.create!(:data => "Area1", :geom => Polygon.from_coordinates([[[12,45],[45,41],[4,1],[12,45]],[[2,5],[5,1],[14,1],[2,5]]],123))
      @a2 = Area.create!(:data => "Area2", :geom => Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],123))
      @a3 = Area.create!(:data => "Area3", :geom => Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],123))
      @r1 = Route.create!(:data => "Route1", :geom => LineString.from_coordinates([[1,1],[3,3]],123))
      @r2 = Route.create!(:data => "Route2", :geom => LineString.from_coordinates([[4,4],[6,6]],123))
      @r3 = Route.create!(:data => "Route3", :geom => LineString.from_coordinates([[7,7],[18,18]],123))
      @p1 = Position.create!(:data => "Point1", :geom => Point.from_x_y(1,1,123))
      @p2 = Position.create!(:data => "Point2", :geom => Point.from_x_y(5,5,123))
      @p3 = Position.create!(:data => "Point3", :geom => Point.from_x_y(8,8,123))

    end

    it "should find the closest other point" do
      @p1.geom.closest(:position, :geom, 123).should == @p2
    end

    it "should find the distance from a linestring" do
      @p1.geom.distance(Route, :geom, 123).should == @p2
    end

end
