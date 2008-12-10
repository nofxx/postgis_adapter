require File.dirname(__FILE__) + '/spec_helper.rb'

describe "PostgisFunctions" do
  before(:all) do
    #load_schema 
    @c1 ||= City.create!(:data => "City1", :geom => Polygon.from_coordinates([[[12,45],[45,41],[4,1],[12,45]],[[2,5],[5,1],[14,1],[2,5]]],123))
    @s1 ||= Street.create!(:data => "Street1", :geom => LineString.from_coordinates([[1,1],[2,2]],123))
    @p1 ||= Position.create!(:data => "Point1", :geom => Point.from_x_y(1,1,123))  
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
