require File.dirname(__FILE__) + '/spec_helper.rb'

describe "PostgisAdapter" do

  describe "Point" do
    it "should record a point nicely" do
      pt = TablePoint.new(:data => "Test", :geom => Point.from_x_y(1.2,4.5))
      pt.save.should be_true
    end

    it "should find a point nicely" do
      find = TablePoint.find(:last)
      find.should be_instance_of(TablePoint)
      find.geom.should be_instance_of(Point)
    end

    it "should find`em all for hellsake..." do
      find = TablePoint.all
      find.should be_instance_of(Array)
      find.last.geom.x.should eql(1.2)
    end

    it "should est_3dz_points" do
      pt = Table3dzPoint.create!(:data => "Hello!",:geom => Point.from_x_y_z(-1.6,2.8,-3.4))
      pt = Table3dzPoint.find(:first)
      pt.geom.should be_instance_of(Point)
      pt.geom.z.should eql(-3.4)
    end

    it "should est_3dm_points" do
      pt = Table3dmPoint.create!(:geom => Point.from_x_y_m(-1.6,2.8,-3.4))
      pt = Table3dmPoint.find(:first)
      pt.geom.should == Point.from_x_y_m(-1.6,2.8,-3.4)
      pt.geom.m.should eql(-3.4)
    end
    it "should est_4d_points" do
      pt = Table4dPoint.create!(:geom => Point.from_x_y_z_m(-1.6,2.8,-3.4,15))
      pt = Table4dPoint.find(:first)
      pt.geom.should be_instance_of(Point)
      pt.geom.z.should eql(-3.4)
      pt.geom.m.should eql(15.0)
    end

    it "should test_keyword_column_point" do
      pt = TableKeywordColumnPoint.create!(:location => Point.from_x_y(1.2,4.5))
      find = TableKeywordColumnPoint.find(:first)
      find.location.should == Point.from_x_y(1.2,4.5)
    end

    it "should test multipoint" do
      mp = TableMultiPoint.create!(:geom => MultiPoint.from_coordinates([[12.4,-4326.3],[-65.1,4326.4],[4326.55555555,4326]]))
      find = TableMultiPoint.find(:first)
      find.geom.should == MultiPoint.from_coordinates([[12.4,-4326.3],[-65.1,4326.4],[4326.55555555,4326]])
    end

  end

  describe "LineString" do
    it "should record a linestring nicely" do
      @ls = TableLineString.new(:value => 3, :geom => LineString.from_coordinates([[1.4,2.5],[1.5,6.7]]))
      @ls.save.should be_true
    end

    it "should find" do
     find = TableLineString.find(:first)
     find.geom.should be_instance_of(LineString)
     find.geom.points.first.y.should eql(2.5)
   end

   it "should test_srid_line_string" do
    ls = TableSridLineString.create!(:geom => LineString.from_coordinates([[1.4,2.5],[1.5,6.7]],4326))
    ls = TableSridLineString.find(:first)
    ls_e = LineString.from_coordinates([[1.4,2.5],[1.5,6.7]],4326)
    ls.geom.should be_instance_of(LineString)
    ls.geom.srid.should eql(4326)
    end


    it "hsould test_multi_line_string" do
      ml = TableMultiLineString.create!(:geom => MultiLineString.from_line_strings([LineString.from_coordinates([[1.5,45.2],[-54.432612,-0.012]]),LineString.from_coordinates([[1.5,45.2],[-54.432612,-0.012],[45.4326,4326.3]])]))
      find = TableMultiLineString.find(:first)
      find.geom.should == MultiLineString.from_line_strings([LineString.from_coordinates([[1.5,45.2],[-54.432612,-0.012]]),LineString.from_coordinates([[1.5,45.2],[-54.432612,-0.012],[45.4326,4326.3]])])
    end
  end

  describe "Polygon" do

    it "should create" do
      pg = TablePolygon.new(:geom => Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]]))
      pg.save.should be_true
    end

    it "should get it back" do
      pg = TablePolygon.find(:first)
      pg.geom.should be_instance_of(Polygon)
      #assert_equal(Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]]),pg.geom)
    end

    it "should test_multi_polygon" do
      mp = TableMultiPolygon.create!( :geom => MultiPolygon.from_polygons([Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]]),Polygon.from_coordinates([[[0,0],[4,0],[4,4],[0,4],[0,0]],[[1,1],[3,1],[3,3],[1,3],[1,1]]])]))
      find = TableMultiPolygon.find(:first)
      find.geom.should == MultiPolygon.from_polygons([Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]]),Polygon.from_coordinates([[[0,0],[4,0],[4,4],[0,4],[0,0]],[[1,1],[3,1],[3,3],[1,3],[1,1]]])])
    end

    it "should test_srid_4d_polygon" do
      pg = TableSrid4dPolygon.create(:geom => Polygon.from_coordinates([[[0,0,2,-45.1],[4,0,2,5],[4,4,2,4.67],[0,4,2,1.34],[0,0,2,-45.1]],[[1,1,2,12.3],[3,1,2,4326],[3,3,2,12.2],[1,3,2,12],[1,1,2,12.3]]],4326,true,true))
      find = TableSrid4dPolygon.find(:first)
      pg_e = Polygon.from_coordinates([[[0,0,2,-45.1],[4,0,2,5],[4,4,2,4.67],[0,4,2,1.34],[0,0,2,-45.1]],[[1,1,2,12.3],[3,1,2,4326],[3,3,2,12.2],[1,3,2,12],[1,1,2,12.3]]],4326,true,true)
      pg.geom.should == pg_e
      pg.geom.srid.should eql(4326)
    end
  end

  describe "Geometry" do


    it "should test_geometry" do
      gm = TableGeometry.create!(:geom => LineString.from_coordinates([[12.4,-45.3],[45.4,41.6],[4.456,1.0698]]))
      find = TableGeometry.find(:first)
      find.geom.should ==  LineString.from_coordinates([[12.4,-45.3],[45.4,41.6],[4.456,1.0698]])
    end

    it "should test_geometry_collection" do
      gc = TableGeometryCollection.create!(:geom => GeometryCollection.from_geometries([Point.from_x_y(4.67,45.4),LineString.from_coordinates([[5.7,12.45],[67.55,54]])]))
      find = TableGeometryCollection.find(:first)
      find.geom.should == GeometryCollection.from_geometries([Point.from_x_y(4.67,45.4),LineString.from_coordinates([[5.7,12.45],[67.55,54]])])
    end

  end

  describe "Find" do
    before(:all) do
      ActiveRecord::Schema.define() do
        create_table "parks", :force => true do |t|
          t.column "data" , :string, :limit => 100
          t.column "value", :integer
          t.column "geom", :point,:null=>false,:srid=>4326
        end
        add_index "parks","geom",:spatial=>true,:name => "example_spatial_index"
      end
      class Park < ActiveRecord::Base
      end
    end

    it "should create some points" do
      Park.create!(:data => "Point1", :geom => Point.from_x_y(1.2,0.75,4326))
      Park.create!(:data => "Point2",:geom => Point.from_x_y(0.6,1.3,4326))
      Park.create!(:data => "Point3", :geom => Point.from_x_y(2.5,2,4326))
    end

    it "should find by geom" do
      pts = Park.find_all_by_geom(LineString.from_coordinates([[0,0],[2,2]],4326))
      pts.should be_instance_of(Array)
      pts.length.should eql(2)
      pts[0].data.should match /Point/
      pts[1].data.should match /Point/
    end

    it "should find by geom again" do
      pts = Park.find_all_by_geom(LineString.from_coordinates([[2.49,1.99],[2.51,2.01]],4326))
      pts[0].data.should eql("Point3")
    end

    it "should find by geom column bbox condition" do
      pts = Park.find_all_by_geom([[0,0],[2,2],4326])
      pts.should be_instance_of(Array)
      pts.length.should eql(2)
      pts[0].data.should match /Point/
      pts[1].data.should match /Point/
    end

    it "should not mess with rails finder" do
      pts = Park.find_all_by_data "Point1"
      pts.should have(1).park
    end

  end

end
