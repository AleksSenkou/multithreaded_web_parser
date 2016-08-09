module Messages
  def current_thread_msg(thread_index = nil)
    "Thread #{Thread.current[:index] || thread_index}".cyan
  end

  def start_fetch_msg(url)
    puts "Start #{url} ".green + current_thread_msg
  end

  def finish_fetch_msg(url)
    puts "Finish #{url}".blue + current_thread_msg
  end

  def error_fetch_msg(e, thread_index)
    puts "Failed: #{e.message} ".red + current_thread_msg(thread_index)
  end
end
