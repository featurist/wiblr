require 'childprocess'

module Apps
  def support_file_path(filename)
    File.join(File.dirname(__FILE__), filename)
  end
  
  def root_file_path(filename)
    File.join(File.dirname(__FILE__), "..", "..", "..", filename)
  end
  
  def start_rudys_app
    $rudys_app_process = start_pogo_process support_file_path("rudys-app.pogo")
  end
  
  def start_wiblr
    $wiblr_process = start_pogo_process root_file_path("src/serve.pogo")
  end
  
  private
  
  def start_pogo_process(path)
    process = ChildProcess.build("pogo", path)
    process.io.inherit! if ENV["INHERIT_IO"] == "true"
    process.start
    process
  end
end