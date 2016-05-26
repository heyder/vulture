#!/usr/bin/ruby1.8

require 'net/http'
require 'net/https'
require 'openssl'
require 'uri'


class HttpRequest

  attr_accessor :url 
  
  def initialize(url)
    @url = url
  end

  def build_http_request(use_proxy,proxy_addr,proxy_port)
    if ((@url.port == 443) or (@url.to_s.match(%r{http(s).*})))
      if (use_proxy)
        http = Net::HTTP.new(@url.host,url.port,proxy_address,proxy_port)
      else
        http = Net::HTTP.new(@url.host,url.port)
      end 
      http.use_ssl=true
      http.verify_mode=OpenSSL::SSL::VERIFY_NONE
      return http
    else
      if (use_proxy)
        http = Net::HTTP.new(@url.host,url.port,proxy_addr,proxy_port)
      else
        http = Net::HTTP.new(@url.host,url.port)
      end 
      return http
    end 
  end

  def myGet(parm)
  end

  def myPost()
  end

end


