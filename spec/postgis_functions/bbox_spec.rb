require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Point" do

  before(:all) do
    @c1 ||= City.create!(:data => "City1", :geom => Polygon.from_coordinates([[[12,45],[45,41],[4,1],[12,45]],[[2,5],[5,1],[14,1],[2,5]]],4326))
    @c2 ||= City.create!(:data => "City1", :geom => Polygon.from_coordinates([[[22,66],[65,65],[20,10],[22,66]],[[10,15],[15,11],[34,14],[10,15]]],4326))
    @c3 ||= City.create!(:data => "City3", :geom => Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],4326))
    @s1 ||= Street.create!(:data => "Street1", :geom => LineString.from_coordinates([[1,1],[2,2]],4326))
    @s2 ||= Street.create!(:data => "Street2", :geom => LineString.from_coordinates([[4,4],[7,7]],4326))
    @s3 ||= Street.create!(:data => "Street3", :geom => LineString.from_coordinates([[8,8],[18,18],[20,20],[25,25],[30,30],[38,38]],4326))
    @s4 ||= Street.create!(:data => "Street3", :geom => LineString.from_coordinates([[10,8],[15,18]],4326))
    @p1 ||= Position.create!(:data => "Point1", :geom => Point.from_x_y(1,1,4326))
    @p2 ||= Position.create!(:data => "Point2", :geom => Point.from_x_y(5,5,4326))
    @p3 ||= Position.create!(:data => "Point3", :geom => Point.from_x_y(8,8,4326))
  end

  describe "BBox operations" do

    it "should check stricly left" do
      @p1.bbox("<<", @c1).should be_true
    end

    it "should check stricly right" do
      @p1.bbox(">>", @c1).should be_false
    end

    it { @p1.should be_strictly_left_of(@c1) }
    it { @p1.should_not be_strictly_right_of(@c1) }
    it { @p1.should_not be_overlaps_or_right_of(@c1) }
    it { @p1.should be_overlaps_or_left_of(@c1) }
    it { @p1.should_not be_completely_contained_by(@c1) }
    it { @c2.completely_contains?(@p1).should be_false }
    it { @p1.should be_overlaps_or_above(@c1) }
    it { @p1.should be_overlaps_or_below(@c1) }
    it { @p1.should_not be_strictly_above(@c1) }
    it { @p1.should_not be_strictly_below(@c1) }
    it { @p1.interacts_with?(@c1).should be_false }

    it { @p1.binary_equal?(@c1).should be_false }
    it { @p1.same_as?(@c1).should be_false }

  end

end
