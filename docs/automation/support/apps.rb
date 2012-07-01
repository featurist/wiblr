require 'childprocess'

module Apps
  def support_file_path(filename)
    File.join(File.dirname(__FILE__), filename)
  end
  
  def root_file_path(filename)
    File.join(File.dirname(__FILE__), "..", "..", filename)
  end
  
  def start_rudys_app
    @rudys_app_process = ChildProcess.build("pogo", support_file_path("rudys-app.pogo"))
    @rudys_app_process.start.io.inherit!
  end
  
  def start_wiblr
    @wiblr_process = ChildProcess.build("pogo", root_file_path("src/serve.pogo"))
    @wiblr_process.start.io.inherit!
  end

  def stop_rudys_app
    @rudys_app_process.stop
  end
  
  def stop_wiblr
    @wiblr_process.stop
  end
end