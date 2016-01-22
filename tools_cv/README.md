These utilities are needed for testing performance of Viola-Jones method , whith callgrind .

Necessary actions:
1 Compile the library Opencv with the flag "-D ENABLE_PROFILING=ON"
2 Compile utilities "make"
3 Enter command "valgrind --tool=callgrind ./program"
4 Enter commad "kcachegrind callgrind.out*"

