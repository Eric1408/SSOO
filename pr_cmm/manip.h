#pragma once

#include <string>
#include <vector>
#include <limits.h>
#include <iostream>
#include <cstdint>

#include <algorithm>
#include <sstream>
#include <unordered_map>

#include <sys/types.h>
#include <sys/stat.h>   // Para stat
#include <unistd.h>     // Para open, read, write y close
#include <utime.h>      // Para utime
#include <libgen.h>     // Para dirname y basename
#include <fcntl.h>      // Para open
#include <system_error> // Para system_error

#include "scope.h"

// PARTE 1
void copy_file(const std::string&, const std::string&, bool);
void move_file(const std::string&, const std::string&);

// PARTE 2

// Mejora la legibilidad del codigo o la empeora?
// typedef std::vector<std::string> command;
namespace shell {
  using command = std::vector<std::string>;
  struct command_result {
    int return_value;
    bool is_quit_requested;
    command_result(int return_value, bool request_quit = false)
      : return_value{return_value}, is_quit_requested{request_quit} {}
    static command_result quit(int return_value = 0) {
      return command_result{return_value, true};
    }
  };
}

std::error_code read_line(int, std::string&);
void print_prompt(int);
std::vector<shell::command> parse_line(const std::string&);