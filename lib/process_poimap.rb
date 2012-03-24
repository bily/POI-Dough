class ProcessSVReport
  def self.perform(params)
    document = SVReport.find!(params["id"])
    
    document.buildings = [ params["bld"].split(",") ]
    document.parks = [ params["prk"].split(",") ]
    document.basemap = "http://otile1.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.png"
    document.createdby = "POI Dough Test"
    document.id = (0...8).map{65.+(rand(25)).chr}.join
    document.updated = Time.now()
    
    #pdf = document.pdf

    #if pdf.grim.count > 0
    #  document.preview = File.open(pdf.create_preview)

    #  pdf.grim.each do |page|
    #    document.page_contents << page.text
    #  end

    #  document.save!
    #else
    #  raise 'PDF has no content'
    #end
    document.save!
  end
end