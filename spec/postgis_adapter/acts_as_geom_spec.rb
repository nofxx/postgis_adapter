require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "ActsAsGeom" do

  before(:each) do
    class DiffColumn < ActiveRecord::Base
      acts_as_geom :ponto
    end

    class NotInDb < ActiveRecord::Base
      acts_as_geom :geom
    end
  end

  it "should get the geom type" do
    City.get_geom_type(:geom).should eql(:polygon)
  end

  it "should not interfere with migrations" do
    NotInDb.get_geom_type(:geom).should be_nil
  end

  it "should set the geom constant" do
#    City::GEOMS[City].should eql([:geom])
  end

  it "should query a diff column name" do
   # DiffColumn
  end

end
