module Sinatra::Helpers
  class JavaScriptRequire
    attr_accessor :orig_path
    def initialize(path)
      @path = @orig_path = path.to_s
    end

    def include_tag
      "<script type='text/javascript' src='#{path}'></script>"
    end

    def embed_tag
      return include_tag if external?
      if content
        "<script type='text/javascript'>\n#{content}\n</script>"
      end
    end

    def <=>(other)
      if external? and other.external?
        0
      elsif external?
        -1
      elsif other.external?
        1
      else
        0
      end
    end

    def external?
      @path.match /^(http|www)/
    end

    def full_path?
      @path.match /\.js$/
    end

    def path
      if external?
        @path
      else
        full_path? ? @path : @path.sub(/$/, '.js')
      end
    end

    def content
      local_path = File.join(Sinatra::Application.root, 'script', path)
      @content ||= File.read( local_path ) if File.exists? local_path
    end
  end

  def javascript(*args)
    @javascript_paths ||= []

    unless args.empty?
      args.map do |path|
        next if @javascript_paths.map(&:orig_path).include? path
        @javascript_paths << JavaScriptRequire.new(path)
      end
      return ''
    else
      @javascript_paths.compact.sort { |a,b| a <=> b }.collect do |path|
        if production?
          path.embed_tag
        else
          path.include_tag
        end
      end.join("\n")
    end
  end

  def javascript_test(*args)
    javascript *args.map { |path| "test/" << path.to_s }
  end

  def css(*args)
    @css_paths ||= []

    unless args.empty?
      args.map! &:to_s
      args.map do |path|
        next if @css_paths.include? path
        @css_paths << path.sub(/(\.css|$)/, '.css')
      end
      return ''
    else
      @css_paths.compact.collect do |path|
        "<link rel='stylesheet' type='text/css' href='#{path}' />"
      end.join("\n")
    end
  end

  def money_string(text)
    return text unless text
    "$%d" % text
  end

  def format_date(date)
    date.strftime("%d-%B")
  end

  def format_datetime(time)
    time.strftime("%d-%B %I:%M%p")
  end

  def yes_or_no(boolean)
    boolean ? "Yes" : "No"
  end

  def google_maps_api_key
    Settings.google_maps_api_key
  end

end
