#include "manip.h"

void copy_file(const std::string& src_path, const std::string& dst_path, bool preserve_all=false) {
  struct stat src_stat;

  // NO EXISTE
  if (stat(src_path.c_str(), &src_stat) == -1) {
    throw std::system_error(ENOENT, std::system_category(), std::string(__FILE__) + " #" + std::to_string(__LINE__));
  }
  // NO ES REGULAR
  if (!S_ISREG(src_stat.st_mode)) {
    throw std::system_error(EISDIR, std::system_category(), std::string(__FILE__) + " #" + std::to_string(__LINE__));
  }
  
  struct stat dst_stat;
  std::string dst_file_path = dst_path;
  
  if (stat(dst_path.c_str(), &dst_stat) == 0) {
    //assert(src_stat.st_ino != dst_stat.st_ino);
    if (src_stat.st_ino == dst_stat.st_ino) {
      throw std::system_error(EEXIST, std::system_category(), std::string(__FILE__) + " #" + std::to_string(__LINE__));
    }
    if (S_ISDIR(dst_stat.st_mode)) {
      std::string src_path_cp = src_path;
      std::string name = basename(const_cast<char*>(src_path_cp.c_str()));
      // Comprobar si dst tiene '/' al final  
      dst_file_path = dst_path + name;
      std::cout << dst_file_path << std::endl;
    }
  }
  {
    int src_fd = open(src_path.c_str(), O_RDONLY);
    if (src_fd < 0) {
      throw std::system_error(EACCES, std::system_category(), std::string(__FILE__) + " #" + std::to_string(__LINE__));
    }
    auto src_guard = scope::make_scope_exit([src_fd]{ close(src_fd); });

    int dst_fd = open(dst_file_path.c_str(), O_WRONLY | O_TRUNC | O_CREAT, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH);
    if (dst_fd < 0) {
      throw std::system_error(EACCES, std::system_category(), std::string(__FILE__) + " #" + std::to_string(__LINE__));
    }
    auto dst_guard = scope::make_scope_exit([dst_fd]{ close(dst_fd); });

    
    std::vector<uint8_t> buffer(16ul * 1024 * 1024);
    // con std::string?
    ssize_t bytes_read;
    while((bytes_read = read(src_fd, buffer.data(), buffer.size())) > 0) {
      // Si write no escriube los mismos bytes que lee
      if (write(dst_fd, buffer.data(), bytes_read) != bytes_read) {
        throw std::system_error(ENOSPC, std::system_category());
      }
      buffer.resize(bytes_read);
    }

    if (bytes_read == -1) {
      throw std::system_error(errno, std::system_category());
    }
  }

  if (preserve_all) {
    try {
      chmod(dst_file_path.c_str(), src_stat.st_mode);
      chown(dst_file_path.c_str(), src_stat.st_uid, src_stat.st_gid);
      struct utimbuf times;
      utime(src_path.c_str(), &times);
      utime(dst_file_path.c_str(), &times);
    } catch (std::system_error& e) {
      std::cerr << "ERROR: " << e.what() << std::endl;
    }
    
  }
}

void move_file(const std::string& src_path, const std::string& dst_path) {
  struct stat src_stat;
  
  if (stat(src_path.c_str(), &src_stat) == -1) {
    throw std::system_error(ENOENT, std::system_category(), std::string(__FILE__) + " #" + std::to_string(__LINE__));
  }
  
  if (!S_ISREG(src_stat.st_mode)) {
    throw std::system_error(EISDIR, std::system_category(), std::string(__FILE__) + " #" + std::to_string(__LINE__));
  }
  
  struct stat dst_stat;
  if (stat(dst_path.c_str(), &dst_stat) < 0) {
    throw std::system_error(ENOENT, std::system_category(), std::string(__FILE__) + " #" + std::to_string(__LINE__));
  }
  
  std::string dst_file_path;
  if (S_ISDIR(dst_stat.st_mode)) {
    std::string src_path_cp = src_path;
    std::string name = basename(const_cast<char*>(src_path_cp.c_str()));
    dst_file_path = dst_path + name;
    //std::cout << dst_file_path << std::endl;
  }
  
  if (dst_stat.st_dev == src_stat.st_dev) {
    if (rename(src_path.c_str(), dst_file_path.c_str()) == -1) {
      throw std::system_error(errno, std::system_category(), std::string(__FILE__) + " #" + std::to_string(__LINE__));
    }
  } else {
    copy_file(src_path, dst_path, true);
    if (unlink(src_path.c_str()) != 0) {
      throw std::system_error(errno, std::system_category(), std::string(__FILE__) + " #" + std::to_string(__LINE__));
    }
  }
}

void print_prompt(int last_command_status) {
  std::string prompt;
  
  if (isatty(STDIN_FILENO)) { 
    try {
      std::string user(getlogin());
      std::string hostnm;
      std::string path;
      gethostname(const_cast<char*>(hostnm.c_str()), hostnm.size());
      getcwd(const_cast<char*>(path.c_str()), path.size());
      prompt = user + "@" + hostnm + ":" + path; 

      if (last_command_status == 0) {
        prompt += "$> ";
      } else {
        prompt += "$< ";
      }

      write(STDIN_FILENO, prompt.c_str(), prompt.size());
    } catch (std::system_error& e) {
      std::cerr << "ERROR: " << e.what() << std::endl; 
    }
  }   
}

std::error_code read_line(int fd, std::string& line) {
  std::vector<uint8_t> pending_input;
  while (true) { 
    try {
      auto it = std::find(pending_input.begin(), pending_input.end(), '\n');
      if (it != pending_input.end()) {
        line.assign(pending_input.begin(), it + 1);
        pending_input.erase(pending_input.begin(), it + 1);
        return {};
      }
      std::vector<uint8_t> buffer(16ul * 1024 * 1024);
      ssize_t bytes_read;
      if ((bytes_read = read(fd, buffer.data(), buffer.size())) == -1) {
        return {errno, std::generic_category()};
      }
      if (buffer.empty()) {
        if (!pending_input.empty()) {
          line.assign(pending_input.begin(), pending_input.end());
          line += '\n';
          pending_input.clear();
        }
        return {};
      } else {
        pending_input.insert(pending_input.end(), buffer.begin(), buffer.begin() + bytes_read);
      }
    } catch (std::system_error& e) {
      std::cerr << "ERROR:" << e.what() << std::endl;
    }
  }
}

std::vector<shell::command> parse_line(const std::string& line) {
  std::vector<shell::command> result;
  std::istringstream iss(line);
  shell::command v_command;
  
  while (!iss.eof()) {
    std::string word;
    iss >> word;
    char c_word = word[word.size() - 1];
    
    if (word[0] == '#') {
      return result;  
    }

    if (c_word == '&' || c_word == ';' || c_word == '|') {
      word.pop_back();
      v_command.push_back(word);
      v_command.push_back(std::string(1, c_word));
      result.push_back(v_command);
      v_command.clear();
    } else {
      v_command.push_back(word);
    }

    if (!v_command.empty()) {
      result.push_back(v_command);
    }

  }

  return result;
}
