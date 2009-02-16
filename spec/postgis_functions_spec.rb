require File.dirname(__FILE__) + '/spec_helper.rb'

describe "PostgisFunctions" do
  before(:all) do
    #load_schema
    @c1 ||= City.create!(:data => "City1", :geom => Polygon.from_coordinates([[[12,45],[45,42],[4,1],[12,45]],[[2,5],[5,1],[14,1],[2,5]]],4326))
    @s1 ||= Street.create!(:data => "Street1", :geom => LineString.from_coordinates([[-43,-20],[-42,-28]],4326))
    @p1 ||= Position.create!(:data => "Point1", :geom => Point.from_x_y(-43,-22,4326))
  end

  describe "Common Mix" do

    it "should calculate distance point to line" do
      @p1.distance_to(@s1).should be_close(0.248069469178417, 0.00000001)
    end

    it "should calculate inside a city" do
      @p1.should_not be_inside(@c1)
    end

    it { @c1.area(32640).should be_close(9165235788987.37, 0.01) }

    it { @c1.area.should be_close(720.0, 0.1) }

    it { @p1.should be_strictly_left_of(@c1) }

    it { @s1.length.should be_close(8.06225774829855, 0.001) }

    it { @s1.length_spheroid.should be_close(891883.597963462,0.0001) }

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
