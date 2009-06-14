require File.dirname(__FILE__) + '/spec_helper.rb'

describe "PostgisFunctions" do
  before(:all) do
    @c1 ||= City.create!(:data => "City1", :geom => Polygon.from_coordinates([[[12,45],[45,42],[4,1],[12,45]],[[2,5],[5,1],[14,1],[2,5]]],4326))
    @s1 ||= Street.create!(:data => "Street1", :geom => LineString.from_coordinates([[-43,-20],[-42,-28]],4326))
    @p1 ||= Position.create!(:data => "Point1", :geom => Point.from_x_y(-43,-22,4326))
    @cg ||= CommonGeo.create!(:data => "Point1", :geom => Point.from_x_y(-43,-22,4326))
    @px = DiffName.create!(:data => "Hey", :the_geom => Point.from_x_y(10,20, 4326))
  end

  describe "Common Mix" do

    it "should calculate distance point to line" do
      @p1.distance_to(@s1).should be_close(0.248069469178417, 0.00000001)
    end

    it "should calculate distance point to line" do
      @cg.distance_to(@s1).should be_close(0.248069469178417, 0.00000001)
    end

     it "should calculate distance point to line" do
      @p1.geom.as_kml.should eql("<Point>\n<coordinates>-43,-22</coordinates>\n</Point>\n")
    end

    it "should calculate inside a city" do
      @p1.should_not be_inside(@c1)
    end

    it "should find the distance from a unsaved point" do
       @p1.distance_to(Point.from_x_y(5,5,4326)).should be_close(55.0726792520575, 0.001)
    end

    it { @c1.area(32640).should be_close(9165235788987.37, 0.01) }

    it { @c1.area.should be_close(720.0, 0.1) }

    it { @p1.should be_strictly_left_of(@c1) }

    it { @s1.length.should be_close(8.06225774829855, 0.001) }

    it { @s1.length_spheroid.should be_close(891883.597963462,0.0001) }

    it "should work with a diff column name" do
      px2 = DiffName.create!(:data => "Hey 2", :the_geom => Point.from_x_y(20,20, 4326))
      @px.distance_to(px2).should be_close(10.0, 0.1)
    end

    it "should work with mixed column names" do
      @px.distance_to(@s1).should be_close(66.4,1)
    end
  end
end
