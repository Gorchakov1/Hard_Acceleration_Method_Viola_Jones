CC              := g++
CC_CROSS        := $(CROSS_COMPILE)g++
OPENCV_PATH     := /
#CFLAGS          := -O0 -I /usr/local/include/opencv -L /usr/local/lib -I /usr/local/include/opencv2
CFLAGS          := -g -pg -O0 -lc -I /tmp/git-opencv/include/ -L /tmp/git-opencv/lib
OBJECTS         := objtest objdetect_capture 
LIBRARIES       := -l opencv_core -l opencv_imgproc -l opencv_highgui -l opencv_objdetect -l opencv_videoio -l opencv_imgcodecs 

all: $(OBJECTS)

objtest: objtest.cpp
	@echo [CC] $<
	$(CC) $(CFLAGS) -o $@ $< $(LIBRARIES)

objtest-arm: objtest.cpp
	@echo [CC] $<
	$(CC_CROSS) $(CFLAGS) -o $@ $< $(LIBRARIES)

objdetect_capture: objdetect_capture.cpp
	@echo [CC] $<
	$(CC) $(CFLAGS) -o $@ $< $(LIBRARIES)
   
clean: 
	rm -f $(OBJECTS)
