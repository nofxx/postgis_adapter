require File.dirname(__FILE__) + '/../spec_helper.rb'


describe "Point" do

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
     @p4 ||= Position.create!(:data => "Point4", :geom => Point.from_x_y(30,30,123))
   
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
       @c1.covers?(@p1).should be_false
     end

     it do
       @c1.covers?(@p4).should be_true
     end

     it do
       @c1.should_not be_within(@c2)
     end

     it "city overlaps point?" do
       @c3.overlaps?(@c2).should raise_error # WHY??
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

     it  do
       @c2.disjoint?(@p2).should be_true
     end
     
     it do
       @c3.polygonize.should have(2).geometries
     end

     # weird...
     # it  do
     #   @c1.disjoint?(@s2).should be_true
     # end

   end
end