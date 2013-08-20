require 'jira'
## monkey patch for progress bar
module JIRA
  class RequestClient

    # Returns the response if the request was successful (HTTP::2xx) and
    # raises a JIRA::HTTPError if it was not successful, with the response
    # attached.

    def request(*args,&block)
      response = make_request(*args,&block)
      raise HTTPError.new(response) unless response.kind_of?(Net::HTTPSuccess)
      response
    end
  end

  class HttpClient < RequestClient

    def make_request(http_method, path, body='', headers={}, &block)
      request = Net::HTTP.const_get(http_method.to_s.capitalize).new(path, headers)
      request.body = body unless body.nil?
      request.basic_auth(@options[:username], @options[:password])
      basic_auth_http_conn.request(request, &block)
    end
  end

  class Client
    def get(path, headers = {}, &block)
      request(:get, path, nil, merge_default_headers(headers), &block)
    end
    def request(http_method, path, body = '', headers={}, &block)
      @request_client.request(http_method, path, body, headers, &block)
    end
  end
end
