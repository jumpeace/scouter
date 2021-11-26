require 'sinatra'
require 'json'

set :environment, :production

def calc_combat_power(image_path)
  result = nil

  File.open(image_path, 'rb') do |image_fp|
    data = image_fp.read
    hash = Digest::SHA256.hexdigest(data)
    result = hash.to_s.slice(0, 4*2).to_i(16)
  end

  return result
end

get '/' do
  @images = []

  Dir.glob('public/files/*').each do |image_path|
    image = {}
    # remove folder-path
    image['name'] = image_path.gsub('public/files/', '')
    image['id'] = image['name'].split('.')[0]
    image['combat_power'] = calc_combat_power(image_path)

    @images << image
  end

  json_src = {}
  json_src['images'] = @images
  @json_data = JSON.generate(json_src)

  erb :index
end

post '/upload' do
  upload_file = params[:file]
  if !upload_file.nil?
    save_path = "./public/files/#{upload_file[:filename]}"
    File.open(save_path, 'wb') do |save_fp|
      upload_fp = upload_file[:tempfile]
      write_data = upload_fp.read
      save_fp.write write_data
    end
  else
    puts 'Upload failed'
  end
  redirect '/'
end
