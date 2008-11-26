require File.dirname(__FILE__) + '/spec_helper.rb'

describe "PostgAdapter" do

  it "should record a point nicely" do
    pt = TablePoint.new(:data => "Test", :geom => Point.from_x_y(1.2,4.5))
    pt.save.should be_true

#    pt = TablePoint.find(:first)
#    assert(pt)
#    assert_equal("Test",pt.data)
#    assert_equal(Point.from_x_y(1.2,4.5),pt.geom)
#
#    pts = TablePoint.find(:all)
#    pts.each do |pt|
#      assert(pt.geom.is_a?(Point))
  end
end
