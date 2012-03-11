$: << File.expand_path('../../lib', __FILE__)

require 'bundler'
Bundler.require

# for URL fetching
require 'uri'
require 'net/http'

# Application module
module PdfArchive
  def self.environment
    ENV['RACK_ENV'] || 'development'
  end

  def self.root
    @root ||= Pathname(File.expand_path('../..', __FILE__))
  end
end

# MongoMapper setup
mongo_url = ENV['MONGOHQ_URL'] || ENV['MONGOLAB_URI'] || "mongodb://localhost:27017/pdf_archive-#{PdfArchive.environment}"
uri = URI.parse(mongo_url)
database = uri.path.gsub('/', '')
MongoMapper.connection = Mongo::Connection.new(uri.host, uri.port, {})
MongoMapper.database = database
if uri.user.present? && uri.password.present?
  MongoMapper.database.authenticate(uri.user, uri.password)
end

# CarrierWave setup
require 'carrierwave/orm/mongomapper'
CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],
    :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY']
  }

  config.fog_directory  = ENV['BUCKET_NAME']
  config.fog_public     = true                                    # optional, defaults to true
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end

# Grim Production Config
if PdfArchive.environment == "production"
  Grim.processor = Grim::MultiProcessor.new([
    Grim::ImageMagickProcessor.new({:ghostscript_path => PdfArchive.root.join('bin', '9.04', 'gs')}),
    Grim::ImageMagickProcessor.new({:ghostscript_path => PdfArchive.root.join('bin', '9.02', 'gs')})
  ])
end

require 'exceptional'
set :raise_errors, true
use Rack::Exceptional, ENV['EXCEPTIONAL_API_KEY'] if ENV['RACK_ENV'] == 'production' && ENV['EXCEPTIONAL_API_KEY']

# require pdf uploader, document model, and process pdf job
require 'uploader'
require 'pdf_uploader'
require 'preview_store'
require 'document'
require 'process_pdf'

# Routes
set :public_folder, "#{PdfArchive.root}/public"

get '/' do
  erb :poihome
end

get '/isometrics/:wayid' do
  
	wayid = params[:wayid]

	if wayid != ''
    	# generate from API: http://www.openstreetmap.org/api/0.6/way/[WAYID]/full
    	# OSM takes awhile to do this, so you should probably have this done with a real server
    	url = 'http://www.openstreetmap.org/api/0.6/way/' + wayid + '/full'
    	url = URI.parse(url)
    	res = Net::HTTP.start(url.host, url.port) {|http|
    	  http.get('/api/0.6/way/' + wayid + '/full')
    	}
    	
		gotdata = res.body.split("\n")
		
		firstpt = ''
		levels = '1'
		name = 'OSM Way'
      
		# opening for this building format
		printout = "buildings.push(
   {
     sections: [
       {
         vertices: [\n"

		gotdata.each do |line|
			if line.index('node id=') != nil
				mylat = line.slice( line.index('lat=')+5 .. line.length )
				mylat = mylat.slice(0 .. mylat.index('"') - 1 )
				mylon = line.slice( line.index('lon=')+5 .. line.length )
				mylon = mylon.slice(0 .. mylon.index('"') - 1 )
				if firstpt == ''
					firstpt = '[ ' + mylat + ', ' + mylon + ' ]'
				end
				printout += "[ " + mylat + ", " + mylon + " ],\n"
			elsif line.index('building:levels') != nil
				# building level count is specified!
				levels = line.slice( line.index('v=')+3 .. line.length )
				levels = levels.slice( 0 .. levels.index('"') - 1 )
			elsif line.index('k="name"') != nil
				# building name is specified!
				name = line.slice( line.index('v=')+3 .. line.length )
				name = name.slice( 0 .. name.index('"') - 1 )
			elsif line.index('/way') != nil
				# repeat first point and close
        		printout += firstpt + "\n         ],\n"

        		# report building levels as 1 if not set otherwise
        		# then finish this section of a building ( add comma if more sections! )
        		printout += '         levels: "' + levels.sub('"','\\"') + "\"\n       }\n"
          
        		# we have no more sections at this time, so finish the list of sections
        		printout += "     ],\n"
          
        		# report name as OSM building if not set otherwise
        		# then close the whole object 
        		printout += '    name: "' + name.sub('"','\\"') + '"'
        		printout += "   }\n);\n"
        		break
        	end
		end
    	printout
	else
		# send default building
		'''buildings.push(
  {
    name: "Burke School",
    sections: [
      {
        levels: 1,
        vertices: [
          [ 32.8193405, -83.6457683 ],
          [ 32.8193103, -83.6455064 ],
          [ 32.8192396, -83.6455179 ],
          [ 32.819198, -83.6451576 ],
          [ 32.8192733, -83.6451184 ],
          [ 32.8192467, -83.6448518 ],
          [ 32.8197124, -83.6447874 ],
          [ 32.8197268, -83.6451034 ],
          [ 32.8199292, -83.6450943 ],
          [ 32.8199793, -83.6454204 ],
          [ 32.8197225, -83.645431 ],
          [ 32.8197552, -83.6457145 ],
          [ 32.8196621, -83.6457297 ],
          [ 32.8193405, -83.6457683 ] // repeat first point
        ]
      }
    ]
  }
);'''
	end
end

get '/textures/:wayid' do
  
	wayid = params[:wayid]

	if wayid != ''
    	# generate from API: http://www.openstreetmap.org/api/0.6/way/[WAYID]/full
    	# OSM takes awhile to do this, so you should probably have this done with a real server
    	url = 'http://www.openstreetmap.org/api/0.6/way/' + wayid + '/full'
    	url = URI.parse(url)
    	res = Net::HTTP.start(url.host, url.port) {|http|
    	  http.get('/api/0.6/way/' + wayid + '/full')
    	}
    	
		gotdata = res.body.split("\n")
		
		firstpt = ''
		levels = '1'
		name = 'OSM Way'
      
		# opening for this building format
		printout = "parks.push(
   {
   	  id: \"" + wayid + "\",
      vertices: [\n"

		gotdata.each do |line|
			if line.index('node id=') != nil
				mylat = line.slice( line.index('lat=')+5 .. line.length )
				mylat = mylat.slice(0 .. mylat.index('"') - 1 )
				mylon = line.slice( line.index('lon=')+5 .. line.length )
				mylon = mylon.slice(0 .. mylon.index('"') - 1 )
				if firstpt == ''
					firstpt = '[ ' + mylat + ', ' + mylon + ' ]'
				end
				printout += "[ " + mylat + ", " + mylon + " ],\n"
			elsif line.index('k="name"') != nil
				# building name is specified!
				name = line.slice( line.index('v=')+3 .. line.length )
				name = name.slice( 0 .. name.index('"') - 1 )
			elsif line.index('/way') != nil
				# repeat first point and close
        		printout += firstpt + "\n         ],\n"

        		# report name as OSM building if not set otherwise
        		# then close the whole object 
        		printout += '    name: "' + name.sub('"','\\"') + '"'
        		printout += "   }\n);\n"
        		break
        	end
		end
    	printout
	end
end

get '/pdf' do
  erb :home
end

post '/pdf' do
  if params['pdf']
    document = Document.create!(params)
    Qu.enqueue(ProcessPdf, document.id)
  end

  erb :home
end

get '/search' do
  @documents = Document.search(params['q'])
  erb :home
end
