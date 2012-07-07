require 'childprocess'
require 'anticipate'

module Apps
  include Anticipate
  
  def support_file_path(filename)
    File.join(File.dirname(__FILE__), filename)
  end
  
  def root_file_path(filename)
    File.join(File.dirname(__FILE__), "..", "..", "..", filename)
  end
  
  def start_rudys_app
    $rudys_app_process ||= start_pogo_process support_file_path("rudys-app.pogo")
    wait_for_response_from "http://localhost:1337/hello"
  end
  
  def start_wiblr
    $wiblr_process ||= start_pogo_process root_file_path("src/serve.pogo")
    wait_for_response_from "http://localhost:8080/"
  end
  
  private
  
  def wait_for_response_from(url)
    sleeping(0.1).seconds.between_tries.failing_after(20).tries do
      RestClient.get url
    end
  end
  
  def start_pogo_process(path)
    process = ChildProcess.build("pogo", path)
    #process.io.inherit!
    process.start
    at_exit do
      process.stop
    end
    process
  end
end