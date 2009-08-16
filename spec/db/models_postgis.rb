class TablePoint < ActiveRecord::Base
end

class TableKeywordColumnPoint < ActiveRecord::Base
end

class TableLineString < ActiveRecord::Base
end

class TablePolygon < ActiveRecord::Base
end

class TableMultiPoint < ActiveRecord::Base
end

class TableMultiLineString < ActiveRecord::Base
end

class TableMultiPolygon < ActiveRecord::Base
end

class TableGeometry < ActiveRecord::Base
end

class TableGeometryCollection < ActiveRecord::Base
end

class Table3dzPoint < ActiveRecord::Base
end

class Table3dmPoint < ActiveRecord::Base
end

class Table4dPoint < ActiveRecord::Base
end

class TableSridLineString < ActiveRecord::Base
end

class TableSrid4dPolygon < ActiveRecord::Base
end

class City < ActiveRecord::Base
  acts_as_geom :geom => :polygon
end

class Position < ActiveRecord::Base
  acts_as_geom :geom => :point
end

class Street < ActiveRecord::Base
  acts_as_geom :geom => :line_string
end

class CommonGeo < ActiveRecord::Base
  acts_as_geom :geom => :point
end

class DiffName < ActiveRecord::Base
  acts_as_geom :the_geom => :point
end
