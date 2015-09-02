class Blinatra
  attr_reader(:env)
  def call(env)
    @env = env
    response
  end

  def response
    [status_code, headers, [body]]
  end

  def status_code
    200
  end

  def body
    return @body if @body
    query_string = env["QUERY_STRING"]
    if query_string.nil?
      `say "YOU DIDNT SEND ANY QUERY PARAMS"`
      @body = "<h1>YOU DIDNT SEND ANY QUERY PARAMS</h1>"
    elsif query_string["to_say"]
      to_say = env["QUERY_STRING"]["to_say"]
      `say "#{to_say}"`
      @body = "<h1>I said #{to_say}</h1>"
    else
      @body = generate_html
    end
  end

  def generate_html
    f = File.open("myhtml.html", "r")
    f.each_line.collect{|line| line}.join
    # "<h1>Brooklyn Forever</h1>"
  end

  def headers
    {"Content-Type"=>"text/html;charset=utf-8", 
      "X-XSS-Protection"=>"1; mode=block", 
      "X-Content-Type-Options"=>"nosniff", 
      "X-Frame-Options"=>"SAMEORIGIN",
      "Content-Length" => content_length}
  end

  def content_length
    body.bytesize.to_s
  end

end