# This script will take a URL and create a local webpage that works, by substituting the URLs the right way

require 'httpclient'
require 'getoptlong'
require 'nokogiri'
require 'open-uri'
require 'my_utilities'

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--url', '-u', GetoptLong::REQUIRED_ARGUMENT]
)

def print_help_and_exit
  puts <<EOS
  #{__FILE__} [options]

  Options:
    -u, --url: URL to download


EOS
  exit 0
end

url = ''

opts.each do |opt, arg|
   case opt
     when '--help'
     MyUtilities::print_help_and_exit
     
     when '--url'
     url = arg.to_s
   end
end
     
if url == ''
  print_help_and_exit
end

class WebpageCopier

  def initialize url
    @url = url
    client = HTTPClient.new
    content = client.get_content(@url)
    @dom_root = Nokogiri::HTML(content)
    @logger = MyUtilities::Logger.new
  end

  def fix_styles
    style_nodes = @dom_root.css 'link'

    style_nodes.each do |node|
      if node['rel']=='stylesheet' then
        src = locate_src node['href']
        name = name_from_url src
        write_to_file src, 'styles'
        
        node['href'] = "styles/#{name}"
      end
    end
  end

  def fix_imgs
    img_nodes = @dom_root.css 'img'

    img_nodes.each do |node|
      src = locate_src node['src']
      name = write_to_file src, 'images'
      
      node['src'] = "images/#{name}" unless name.nil?
    end
  end

  def print filename
    File.open(filename, 'w') do |handle|
      handle.write(@dom_root.to_html)
    end
  end

  private

  def make_dir(dirname)
    # Create the directory if it doesn't already exist
    unless Dir.exists? dirname
      Dir.mkdir dirname
    end
  end
    

  def write_to_file(src, write_dir)
    name = name_from_url src
    puts "Writing to file #{name}"

    make_dir write_dir

    begin
      File.open("#{write_dir}/#{name}", 'wb') do |write_f|
        read_handle = open(src, 'rb')
        while (buff = read_handle.read(1024))
          write_f.write(buff)
        end
      end

    rescue OpenURI::HTTPError => exc
      @logger.fatal("Fetch error for URL, message is #{exc.message}")
      return nil
    end

    return name
  end

  def locate_src src_input
    src_str = src_input
    if src_str && src_str != '' then

      if !(/^https?:\/\//.match(src_str)) then
        # Make the image URL absolute if it is relative
        src_str = @url + (/\/$/.match(@url)? "":"/") + src_str
      end
    end

    puts "Downloading img from #{src_str}"

    return src_str
  end

  def name_from_url(url)
    matches = /([^\/]+)$/.match url
    
    return nil if matches.nil? 

    return matches[1]
  end
end

copier = WebpageCopier.new url
copier.fix_imgs 
copier.fix_styles

copier.print "index.html"
