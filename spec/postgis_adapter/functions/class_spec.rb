require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe "ClassMethods" do
  before(:all) do
    @c1 ||= City.create!(:data => "CityClass", :geom => Polygon.from_coordinates([[[12,45],[45,41],[4,1],[12,45]],[[2,5],[5,1],[14,1],[2,5]]],4326))
    @c2 ||= City.create!(:data => "CityClass", :geom => Polygon.from_coordinates([[[10,10],[10,50],[50,50],[10,10]],[[2,5],[5,1],[14,1],[2,5]]],4326))
    @s1 ||= Street.create!(:data => "StreetClass", :geom => LineString.from_coordinates([[1,1],[99,88]],4326))
    @s2 ||= Street.create!(:data => "StreetClassTiny", :geom => LineString.from_coordinates([[1,1],[1.1,1.1]],4326))
    @p1 ||= Position.create!(:data => "PointClass", :geom => Point.from_x_y(99,99,4326))
    @p2 ||= Position.create!(:data => "PointClassClose", :geom => Point.from_x_y(99.9,99.9,4326))
    @p3 ||= Position.create!(:data => "PointInsideCity", :geom => Point.from_x_y(15.0,15.0,4326))

    # covered by @c2
    @p4 ||= Position.create!(:data => "PointInsideCity", :geom => Point.from_x_y(11.0,49.0,4326))
  end

  after(:all) do
    [City, Street, Position].each { |m| m.delete_all }
  end

  it "should find the closest other point" do
    Position.close_to(Point.from_x_y(99,99,4326), :srid => 4326)[0].data.should == @p1.data
  end

  it "should find the closest other point and limit" do
    Position.close_to(Point.from_x_y(99,99,4326), :limit => 2).should have(2).positions
  end

  it "should find the closest other point" do
    Position.closest_to(Point.from_x_y(99,99,4326)).data.should == @p1.data
  end

  it "should sort by size" do
    Street.by_length.first.data.should == "StreetClassTiny"
    Street.by_length.last.data.should == "StreetClass"
  end

  it "largest" do
    Street.longest.data.should == "StreetClass"
  end

  it "should sort by linestring length" do
    Street.by_length.should be_instance_of(Array)
  end

  it "should sort by linestring length" do
    Street.by_length(:limit => 2).should have(2).streets
  end

  it "should find the longest" do
    Street.longest.should == @s1
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

  it "should sort by all dwithin" do
    City.all_dwithin(@s1.geom).should eql([@c1, @c2])
  end

  it "should find all within polygon" do
    Position.all_within(@c1.geom).should eql([@p3])#Array)
  end

  it "should find all within polygon 2" do
    Position.all_within(@c2.geom).should eql([])#Array)
  end

  it "should sort by all within" do
    City.by_boundaries.should be_instance_of(Array)
  end

  it "should find all covered by" do
    Position.covered_by(@p4.geom).should eql([@c2])#Array)
  end

end
