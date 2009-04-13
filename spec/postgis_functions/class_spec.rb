require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Class Functions" do
  before(:all) do
    @c1 ||= City.create!(:data => "City1", :geom => Polygon.from_coordinates([[[12,45],[45,41],[4,1],[12,45]],[[2,5],[5,1],[14,1],[2,5]]],4326))
    @s1 ||= Street.create!(:data => "Street1", :geom => LineString.from_coordinates([[1,1],[88,88]],4326))
    @p1 ||= Position.create!(:data => "Point1", :geom => Point.from_x_y(1,1,4326))
  end

  it "should find the closest other point" do
    Position.close_to(@p1.geom, :srid => 4326)[0].data.should == @p1.data
  end

  it "should find the closest other point and limit" do
    Position.close_to(@p1.geom, :limit => 10).should have(10).positions
  end

  it "should find the closest other point" do
    Position.closest_to(@p1.geom).data.should == @p1.data
  end

  it "should sort by linestring length" do
    Street.by_length.should be_instance_of(Array)
  end

  it "should sort by linestring length" do
    Street.by_length(:limit => 10).should have(10).streets
  end

  it "should find the longest" do
    Street.longest.should be_instance_of(Street)
  end

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
