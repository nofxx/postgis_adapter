require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "CommonSpatialAdapter" do

  class Park < ActiveRecord::Base;  end
  class Viewpark < ActiveRecord::Base;  end

  describe "Migration" do

    before(:all) do
      @connection = ActiveRecord::Base.connection
      ActiveRecord::Schema.define do
        create_table "parks", :force => true do |t|
          t.string "data",  :limit => 100
          t.integer "value"
          t.polygon "geom", :null => false, :srid => 4326 , :with_z => true, :with_m => true
        end
      end
    end

    it "should test_creation_modification" do
      @connection.columns("parks").length.should eql(4) # the 3 defined + id
    end

    it "should test columns" do
      @connection.columns("parks").each do |col|
        if col.name == "geom"
          col.class.should eql(ActiveRecord::ConnectionAdapters::SpatialPostgreSQLColumn)
          col.geometry_type.should eql(:polygon)
          col.type.should eql(:geometry)
          col.null.should be_false
          col.srid.should eql(4326)
          col.with_z.should be_true
          col.with_m.should be_true
        end
      end
    end

    describe "Add" do

      before(:all)do
        ActiveRecord::Schema.define do
          add_column "parks","geom2", :multi_point
        end
      end

      it "should test_creation_modification" do
        @connection.columns("parks").length.should eql(5) # the 3 defined + id
      end

      it "should test columns" do
        @connection.columns("parks").each do |col|
          if col.name == "geom2"
            col.class.should eql(ActiveRecord::ConnectionAdapters::SpatialPostgreSQLColumn)
            col.geometry_type.should eql(:multi_point)
            col.type.should eql(:geometry)
            col.null.should be_true
            col.srid.should eql(-1)
            col.with_z.should be_false
            col.with_m.should be_false
          end
        end
      end
    end

    describe "remove" do
      before(:all) do
        ActiveRecord::Schema.define do
          remove_column "parks","geom2"
        end
      end

      it "should test_creation_modification" do
        @connection.columns("parks").length.should eql(4) # the 3 defined + id
      end

      it "should get rid of the right one" do
        @connection.columns("parks").each do |col|
          violated if col.name == "geom2"
        end
      end
    end

    describe "indexes" do

      it "should have 0 indexes" do
        @connection.indexes("parks").length.should eql(0)
      end

      it "should create one" do
        ActiveRecord::Schema.define do
          add_index "parks","geom",:spatial=>true
        end
        @connection.indexes("parks").length.should eql(1)
        @connection.indexes("parks")[0].spatial.should be_true
      end

      it "should remove too" do
        ActiveRecord::Schema.define do
          remove_index "parks", "geom"
        end
        @connection.indexes("parks").length.should eql(0)
      end

      it "should work with points" do
        ActiveRecord::Schema.define do
          remove_column "parks","geom2"
          add_column "parks","geom2", :point
          add_index "parks","geom2",:spatial=>true,:name => "example_spatial_index"
        end
        @connection.indexes("parks").length.should eql(1)
        @connection.indexes("parks")[0].spatial.should be_true
        @connection.indexes("parks")[0].name.should eql("example_spatial_index")
      end

    end

  end

  describe "Keywords" do

    before(:all) do
    ActiveRecord::Schema.define do
      create_table "parks", :force => true do |t|
        t.string "data", :limit => 100
        t.integer "value"
        #location is a postgreSQL keyword and is surrounded by double-quotes ("") when appearing in constraint descriptions ; tests a bug corrected in version 39
        t.point "location", :null=>false,:srid => -1, :with_m => true, :with_z => true
      end
    end

    @connection = ActiveRecord::Base.connection
    @columns = @connection.columns("parks")
    end

    it "should get the columsn length" do
      @connection.indexes("parks").length.should eql(0) # the 3 defined + id
    end

    it "should get the columns too" do
      @connection.columns("parks").each do |col|
        if col.name == "geom2"
          col.class.should eql(ActiveRecord::ConnectionAdapters::SpatialPostgreSQLColumn)
          col.geometry_type.should eql(:point)
          col.type.should eql(:geometry)
          col.null.should be_true
          col.srid.should eql(-1)
          col.with_z.should be_false
          col.with_m.should be_false
        end
      end
    end
  end

  describe "Views" do

    before(:all) do
      ActiveRecord::Schema.define do
        create_table "parks", :force => true do |t|
          t.column "data" , :string, :limit => 100
          t.column "value", :integer
          t.column "geom", :point,:null=>false
        end
      end

      Park.create!(:data => "Test", :geom => Point.from_x_y(1.2,4.5))

      ActiveRecord::Base.connection.execute('CREATE VIEW viewparks as SELECT * from parks')
      #if not ActiveRecord::Base.connection.execute("select * from geometry_columns where f_table_name = 'viewparks' and f_geometry_column = 'geom'") #do not add if already there
        #mark the geom column in the view as geometric
        #ActiveRecord::Base.connection.execute("insert into geometry_columns values ('','public','viewparks','geom',2,-1,'POINT')")
      #end
    end

    it "should works" do
      pt = Viewpark.find(:first)
      pt.data.should eql("Test")
      pt.geom.should == Point.from_x_y(1.2,4.5)
    end

    after(:all) do
      ActiveRecord::Base.connection.execute('DROP VIEW viewparks')
    end
  end

  describe "Dump" do
    before(:all) do
      #Force the creation of a table
      ActiveRecord::Schema.define do
        create_table "parks", :force => true do |t|
          t.string "data" , :limit => 100
          t.integer "value"
          t.multi_polygon "geom", :null=>false,:srid => -1, :with_m => true, :with_z => true
        end
      add_index "parks","geom",:spatial=>true,:name => "example_spatial_index"
      end
      #dump it : tables from other tests will be dumped too but not a problem
      File.open('schema.rb', "w") do |file|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
      #load it again
      load('schema.rb')
      #delete the schema file
      File.delete('schema.rb')
      @connection = ActiveRecord::Base.connection
      @columns = @connection.columns("parks")
    end

    it "should create" do
      @columns.length.should eql(4) # the 3 defined + id
    end

    it "should get the same stuff bakc" do
      @columns.each do |col|
          if col.name == "geom"
            col.class.should eql(ActiveRecord::ConnectionAdapters::SpatialPostgreSQLColumn)
            col.geometry_type.should eql(:multi_polygon)
            col.type.should eql(:geometry)
            col.null.should be_false
            col.srid.should eql(-1)
            col.with_z.should be_true
            col.with_m.should be_true
          end
        end
    end

    it "should get the indexes back too" do
      @connection.indexes("parks").length.should eql(1)
      @connection.indexes("parks")[0].spatial.should be_true
      @connection.indexes("parks")[0].name.should eql("example_spatial_index")
    end
  end


  describe "Fixtures" do

    it "should test_long_fixture" do
      Polygon.from_coordinates([[[144.857742,13.598263],
[144.862362,13.589922],[144.865169,13.587336],[144.862927,13.587665],
[144.861292,13.587321],[144.857597,13.585299],[144.847845,13.573858],
[144.846225,13.571014],[144.843605,13.566047],[144.842157,13.563831],
[144.841202,13.561991],[144.838305,13.556465],[144.834645,13.549919],
[144.834352,13.549395],[144.833825,13.548454],[144.831839,13.544451],
[144.830845,13.54081],[144.821543,13.545695],[144.8097993,13.55186285],
[144.814753,13.55755],[144.816744,13.56176944],[144.818862,13.566258],
[144.819402,13.568565],[144.822373,13.572223],[144.8242032,13.57381149],
[144.82634,13.575666],[144.83416,13.590365],[144.83514,13.595657],
[144.834284,13.59652],[144.834024,13.598031],[144.83719,13.598061],
[144.857742,13.598263]]]).to_fixture_format.split(/\s+/).should eql(["0103000020FFFFFFFF0100000020000000FBCC599F721B62404ED026874F322B40056A3178981B6240BF61A2410A2E2B406B10E676AF1B6240E486DF4DB72C2B40BC7A15199D1B6240F701486DE22C2B40CE893DB48F1B62400E828E56B52C2B40BA84436F711B624054C37E4FAC2B2B407862D68B211B62408F183DB7D0252B40D8817346141B6240C51D6FF25B242B40BFB7E9CFFE1A624071FF91E9D0212B401EA33CF3F21A624024F1F274AE202B408EEA7420EB1A6240ED4ACB48BD1F2B4058E20165D31A6240BEBC00FBE81C2B40A3586E69B51A6240E6E5B0FB8E192B40452BF702B31A6240FE2B2B4D4A192B40CA32C4B1AE1A624084B872F6CE182B403291D26C9E1A62408B8C0E48C2162B4072E14048961A624014B35E0CE5142B403FA88B144A1A6240732EC55565172B405CBA38E0E9196240344179C48D1A2B402C2AE274121A624005C58F31771D2B40892650C4221A62406D62793EA01F2B40FDBD141E341A62405D328E91EC212B40DD088B8A381A6240EC4CA1F31A232B40A1832EE1501A6240BB09BE69FA242B4046A863DF5F1A6240F23C9F9ECA252B400D6C9560711A624099D6A6B1BD262B4034F44F70B11A6240F5673F52442E2B409B728577B91A624056444DF4F9302B406FF25B74B21A6240E1D1C6116B312B4088821953B01A624005FD851E31322B4039D1AE42CA1A6240AF06280D35322B40FBCC599F721B62404ED026874F322B40"])
    end

  end

end
