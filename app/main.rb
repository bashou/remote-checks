require 'rubygems'
require 'sinatra/base'
require 'benchmark'
require 'json'
require 'net/http'
require 'net/https'
require 'uri'

class NetChecks < Sinatra::Base

# If try to access to root, do redirect => skillstar.com
# HTTP Response : 302
  get '/' do
    "Check Box <br/>
    <hr>
    - <a href='/checks/pagetest'>Pagetest</a><br/>
    -- Example : /checks/pagetest?proxy=http://your.proxy&url=http://www.france2.fr/ "
    #redirect 'http://www.dotinfra.fr'
  end

# Getting JSON serialized return of checks
  get '/checks/pagetest' do
    content_type :json

    url = "#{params[:url]}"
    proxy = "#{params[:proxy]}"

    stats = Benchmark.realtime { @result = http_get(URI(proxy), URI(url)) }

      json = { :HTTP_Check => {
        :request_to              => "#{url}",
        :response_code           => "#{@result.code}",
        :response_time           => "#{stats}",
        :cachecontrol            => "#{@result.header.get_fields('Cache-Control').first.to_s}"
      }
      }
      JSON.pretty_generate(json)
  end

# Define methods
  def http_get(proxy,uri)
    user_agent = 'Mozilla/5.0 (Forge; check cache control)'
    connect = Net::HTTP.new(proxy.host, proxy.port)
    req = Net::HTTP::Get.new(uri.request_uri, {'Host' => uri.host,'User-Agent' => user_agent})
    req.basic_auth uri.user, uri.password
    resp, data = connect.request(req)
  end

end
