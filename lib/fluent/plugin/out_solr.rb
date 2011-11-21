module Fluent

require 'solr'

class SolrOutput < Fluent::BufferedOutput
  Fluent::Plugin.register_output('solr', self)
  include SetTimeKeyMixin
  include SetTagKeyMixin
  config_set_default :include_time_key, true
  config_set_default :include_tag_key, true
  config_set_default :time_format, "%Y%m%d%H%M%S%L"

  def initialize
    super
    require 'msgpack'
    require 'socket'
  end

  def configure(conf)
    super

    @host = conf.has_key?('host') ? conf['host'] : 'localhost'
    @port = conf.has_key?('port') ? conf['port'] : '8983'
    @core = conf.has_key?('core') ? conf['core'] : ''

  end

  def start
    super
    @connection = Solr::Connection.new('http://'+@host+':'+@port+'/solr/'+@core)
  end

  def shutdown
    super
  end

  def format(tag, time, record)
    record.to_msgpack
  end

  def write(chunk)
    chunk.msgpack_each  { |record|
      doc = Solr::Document.new(
        :id => record["tag"] + "_" + Socket::gethostname + "_" + record["core"] + "_" + record["thread"] + "_" + record["timestamp"].gsub(/[\s\.:-]/, ""), 
        :host_s => Socket::gethostname,
        :timestamp_s => record["timestamp"],
        :level_s => record["level"],
        :thread_s => record["thread"],
        :class_s => record["class"],
        :core_s => record["core"],
        :webapp_s => record["webapp"],
        :path_s => record["path"],
        :params_s => record["params"],
        :hits_tl => record["hits"],
        :status_ti => record["status"],
        :qtime_tl => record["qtime"],
        :time_tl => record["time"],
        :tag_s => record["tag"]
      )
      request = Solr::Request::AddDocument.new(doc)
      response = @connection.send(request)
      if response.ok?
        options={}
        options.update(:softCommit => "true")
        response = @connection.send(Solr::Request::Commit4.new(options))
      end
    }
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
