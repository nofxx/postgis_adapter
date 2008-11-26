module PostgisFunctions

  def close_to(point)
    lambda { |p| {:order => "Distance(geom, GeomFromText('POINT(#{p.x} #{p.y})', 4326))" }}
  end


  def x;  geom ? geom.x : nil;  end
  def y;  geom ? geom.y : nil;  end
  def z;  geom ? geom.z : nil;  end

end



class GeoRuby::SimpleFeatures::LineString
  def pass_by(point,margin=500)

  end

end

class GeoRuby::SimpleFeatures::Point

  def distance(other)
  "SELECT Distance(geom, GeomFromText('POINT(#{other.x} #{other.y})')" #SRID?
  end

  def inside?(polygon)
  "geom WITHIN(polygon)"
  end

  def outside?
    !inside?
  end

  def next_to(line,margin=500)

  end
end

class GeoRuby::SimpleFeatures::Polygon

  def contains?(point)

  end

end
