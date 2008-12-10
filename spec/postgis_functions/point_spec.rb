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
   end
   
   

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

   it do
     @p1.azimuth(@p2).should be_close(0.785398163397448,0.000001)
   end

   it do
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

   it  do
     @p1.disjoint?(@s2).should be_true
   end

   it do
     @p3.polygonize.geometries.should be_empty
   end

end

