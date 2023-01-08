#include <iostream>
#include <cstdlib>

#include "manip.h"

int main(int argc, char* argv[]) {
  std::string aux = argv[1];
  std::string arg_1;
  std::string arg_2;
  if (aux == "-m") {
    arg_1 = argv[2];
    arg_2 = argv[3];
    move_file(arg_1, arg_2);
  } else if (aux == "-a") {
    arg_1 = argv[2];
    arg_2 = argv[3];
    copy_file(arg_1, arg_2, true);
  } else {
    arg_1 = argv[1];
    arg_2 = argv[2];
    copy_file(arg_1, arg_2, false);
  }
  
  return 0;
}