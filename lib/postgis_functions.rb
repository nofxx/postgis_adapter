module PostgisFunctions

  def close_to(point)

  end

end


class GeoRuby::SimpleFeatures::LineString
  def distance(line)

  end

end

class GeoRuby::SimpleFeatures::Point

  def inside?(polygon)

  end

  def outside?
    !inside?
  end

  def next_to(line)

  end
end

class GeoRuby::SimpleFeatures::Polygon

  def contains?(point)

  end

end

 # IsEnclosedByAssociation
  # => SmallRegionOrPoint is_enclosed_by LargerRegion
  # => Example: City is_enclosed_by State
  def is_enclosed_by(*enclosingModels)
    enclosingModels.each do |enclosingModel|
      enclosing_model_name = enclosingModel.to_s
      enclosingclass = eval("#{enclosing_model_name.camelcase}")
      define_method("#{enclosingModel}") do
        results = enclosingclass.find_by_sql("select b.* from #{self.class.to_s.tableize} a, #{enclosing_model_name.tableize} b where within(a.geometry,b.geometry) and a.id = #{self.id};")[0]
        instance_variable_set("@#{enclosingModel}", results)
      end
    end
  end

  # EnclosesAssociation
  # => LargerRegion encloses SmallerRegionOrPoints
  # => Example: State encloses City
  def encloses(*enclosingModels)
    enclosingModels.each do |enclosingModel|
      enclosing_model_name = enclosingModel.to_s.singularize
      enclosingclass = eval("#{enclosing_model_name.camelcase}")
      define_method("#{enclosing_model_name.pluralize}") do
        results = enclosingclass.find_by_sql("select a.* from #{enclosing_model_name.tableize} a, #{self.class.to_s.tableize} b where within(a.geometry,b.geometry) and b.id = #{self.id};")
        instance_variable_set("@#{enclosing_model_name.pluralize}", results)
      end
    end
  end








end
