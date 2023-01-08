CXX = g++
CXXFLAGS = -std=c++11 -g -Wall

all: cmd

cmd: manip.o main.o
	$(CXX) $(CXXFLAGS) -o $@ $^ 

.PHONY: all clean
	$(CXX) $(CXXFLAGS) -c $<

clean:
	rm -rf *.o
