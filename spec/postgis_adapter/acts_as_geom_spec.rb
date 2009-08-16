require File.dirname(__FILE__) + '/../spec_helper.rb'

class DiffColumn < ActiveRecord::Base
  acts_as_geom :ponto => :point
end

class NotInDb < ActiveRecord::Base
  acts_as_geom :geom
end

describe "ActsAsGeom" do

  it "should get the geom type" do
    City.connection.columns("cities").select { |c| c.name == "geom" }[0]
    City.get_geom_type(:geom).should eql(:polygon)
  end

  it "should get the geom type" do
    Position.get_geom_type(:geom).should eql(:point)
  end

  it "should not interfere with migrations" do
    NotInDb.get_geom_type(:geom).should be_nil
  end

  it "should query a diff column name" do
   # DiffColumn
  end

end
