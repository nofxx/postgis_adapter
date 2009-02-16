###
##
#
# BBox
#
#
module PostgisFunctions

  #
  # These operators utilize indexes. They compare geometries by bounding boxes.
  #
  # You can use the literal forms or call directly using the 'bbox' method. eg.:
  #
  #   @point.bbox(">>", @area)
  #   @point.bbox("|&>", @area)
  #
  #
  # Cheatsheet:
  #
  #   A &< B    =>    A overlaps or is to the left of B
  #   A &> B    =>    A overlaps or is to the right of B
  #   A << B    =>    A is strictly to the left of B
  #   A >> B    =>    A is strictly to the right of B
  #   A &<| B   =>    A overlaps B or is below B
  #   A |&> B   =>    A overlaps or is above B
  #   A <<| B   =>    A strictly below B
  #   A |>> B   =>    A strictly above B
  #   A = B     =>    A bbox same as B bbox
  #   A @ B     =>    A completely contained by B
  #   A ~ B     =>    A completely contains B
  #   A && B    =>    A and B bboxes interact
  #   A ~= B    =>    A and B geometries are binary equal?
  #
  def bbox(operator, other)
    postgis_calculate(:bbox, [self, other], operator)
  end

  #
  #  bbox literal method.
  #
  def completely_contained_by? other
    bbox("@", other)
  end

  #
  #  bbox literal method.
  #
  def completely_contains? other
    bbox("~", other)
  end

  #
  #  bbox literal method.
  #
  def overlaps_or_above? other
    bbox("|&>", other)
  end

  #
  #  bbox literal method.
  #
  def overlaps_or_below? other
    bbox("&<|", other)
  end

  #
  #  bbox literal method.
  #
  def overlaps_or_left_of? other
    bbox("&<", other)
  end

  #
  #  bbox literal method.
  #
  def overlaps_or_right_of? other
    bbox("&>", other)
  end

  #
  #  bbox literal method.
  #
  def strictly_above? other
    bbox("|>>", other)
  end

  #
  #  bbox literal method.
  #
  def strictly_below? other
    bbox("<<|", other)
  end

  #
  #  bbox literal method.
  #
  def strictly_left_of? other
    bbox("<<", other)
  end

  #
  #  bbox literal method.
  #
  def strictly_right_of? other
    bbox(">>", other)
  end

  #
  #  bbox literal method.
  #
  def interacts_with? other
    bbox("&&", other)
  end

  #
  #  bbox literal method.
  #
  def binary_equal? other
    bbox("~=", other)
  end

  #
  #  bbox literal method.
  #
  def same_as? other
    bbox("=", other)
  end
end
