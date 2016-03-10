require 'faraday'
require 'json'

class Hoarder::Client

  attr_reader :host
  attr_reader :token

  def initialize(host='127.0.0.1', token='123')
    @host  = host
    @token = token
  end

  # List blobs
  def blobs
    get '/blobs'
  end

  # Retrieve metadata about a specific blob
  def blob(id)
    head "/blobs/#{id}"
  end

  # Delete a blob
  def remove_blob(id)
    delete "/blobs/#{id}"
  end

  protected

  def head(path)
    res = connection.get(path) do |req|
      req.headers['X-TOKEN'] = token
    end

    if res.status == 200
      from_json(res.body) rescue ""
    else
      raise "#{res.status}:#{res.body}"
    end
  end

  def get(path)
    res = connection.get(path) do |req|
      req.headers['X-TOKEN'] = token
    end

    if res.status == 200
      from_json(res.body) rescue ""
    else
      raise "#{res.status}:#{res.body}"
    end
  end

  def post(path, payload)
    res = connection.post(path) do |req|
      req.headers['X-TOKEN'] = token
      req.body = to_json(payload)
    end

    if res.status == 200
      from_json(res.body) rescue ""
    else
      raise "#{res.status}:#{res.body}"
    end
  end

  def put(path, payload)
    res = connection.put(path) do |req|
      req.headers['X-TOKEN'] = token
      req.body = to_json(payload)
    end

    if res.status == 200
      from_json(res.body) rescue ""
    else
      raise "#{res.status}:#{res.body}"
    end
  end

  def delete(path, payload={})
    res = connection.delete(path) do |req|
      req.headers['X-TOKEN'] = token
      if payload
        req.body = to_json(payload)
      end
    end

    if res.status == 200
      true
    else
      raise "#{res.status}:#{res.body}"
    end
  end

  def connection
    @connection ||= ::Faraday.new({
      url: "https://#{host}:7410",
      :ssl => {:verify => false}
    })
  end

  def to_json(data)
    JSON.dump(data)
  end

  def from_json(data)
    JSON.parse(data)
  end

end