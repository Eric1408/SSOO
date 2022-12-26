#include <iostream>
#include <cstdlib>
#include "usage.h"

void copy_file(const std::string& src_path, const std::string& dst_path, bool preserve_all=false) {

}

void move_file(const std::string& src_path, const std::string& dst_path);

int main(int argc, char* argv[]) {
  Usage(argc, argv);
  std::string option = argv[1];
  if (option == "-m") {
    
  } else if (option == "a") {

  }
 
  return 0;
}