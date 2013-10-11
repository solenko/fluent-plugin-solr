module Fluent

require 'solr'

class SolrOutput < Fluent::BufferedOutput
  Fluent::Plugin.register_output('solr', self)
  include SetTimeKeyMixin
  include SetTagKeyMixin
  config_set_default :include_time_key, false
  config_set_default :include_tag_key, false
  config_set_default :time_format, "%Y%m%d%H%M%S%L"

  attr_reader :host
  attr_reader :path
  attr_reader :port
  attr_reader :core

  def initialize
    super
    require 'msgpack'
    require 'socket'
  end

  def configure(conf)
    super

    @host = conf.fetch('host', 'localhost')
    @path = conf.fetch('path', 'solr')
    @port = conf.fetch('port', '8983')

    @core = conf.fetch('core', '')

  end

  def start
    super
    @connection = RSolr.connect :url => "http://#{host}:#{port}/#{path}/#{core}"
  end

  def shutdown
    super
  end

  def format(tag, time, record)
    [tag, time, record].to_msgpack
  end

  def write(chunk)
    bulk_docs = []
    chunk.msgpack_each do |tag, time, record|
      doc = record.inject({}) do |memo, data|
        memo[to_solr_field(*data)] = data.last
      end
      doc[tag_key] = tag
      doc[time_key] = time
      bulk_docs << doc
    end

    response = @connection.add(bulk_docs)
  end

  def to_solr_field(original_name, value)
    original_name
  end

end

class Solr::Request::Commit4 < Solr::Request::Update

  def initialize(options={})
    @wait_searcher = options[:wait_searcher] || true
    @soft_commit = options[:soft_commit] || false
  end


  def to_s
    e = Solr::XML::Element.new('commit')
    e.attributes['waitSearcher'] = @wait_searcher ? 'true' : 'false'
    e.attributes['softCommit'] = @soft_commit ? 'true' : 'false'
    
    e.to_s
  end

end

class Solr::Response::Commit4 < Solr::Response::Xml
end

end
