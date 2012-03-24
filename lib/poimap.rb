class POIMap
  include MongoMapper::Document
  plugin Hunt

  key :id, Integer
  key :buildings, Array
  key :parks, Array
  key :basemap, String
  key :createdby, String
  key :updated, Time
  
  searches :id, :buildings, :createdby
end