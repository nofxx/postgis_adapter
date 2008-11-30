require File.dirname(__FILE__) + '/spec_helper.rb'

describe "ActsAsGeom" do

  before(:each) do
    class City < ActiveRecord::Base
      acts_as_geom :geom
    end
  end

  it "should get the geom type" do
    City.get_geom_type(:geom).should eql(:polygon)
  end

end
