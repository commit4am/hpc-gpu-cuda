NVCC		= nvcc
CC		= g++
CU_FLAGS	= -O3 -g --ptxas-options=-v
CC_FLAGS	= -O3 -m64 -Wall

CU_SOURCES	= vector-add.cu
CU_EV_SOURCES	= vector-add-events.cu
CC_SOURCES	= timer.cc

CU_OBJECTS	= $(CU_SOURCES:%.cu=%.o)
CU_EV_OBJECTS	= $(CU_EV_SOURCES:%.cu=%.o)
CU_PTX		= $(CU_SOURCES:%.cu=%.ptx)
CU_EV_PTX	= $(CU_EV_SOURCES:%.cu=%.ptx)
CC_OBJECTS	= $(CC_SOURCES:%.cc=%.o)

%.o:		%.cu
		$(NVCC) $(CU_FLAGS) -c $< -o $@

%.o:		%.cc
		$(CC) $(CC_FLAGS) -c $< -o $@

%.ptx:		%.cu
		$(NVCC) $(CU_FLAGS) --ptx $< -o $@

vector-add:	$(CU_OBJECTS) $(CC_OBJECTS)
		$(NVCC) $^ -o $@

vector-add-events:	$(CU_EV_OBJECTS) $(CC_OBJECTS)
			$(NVCC) $^ -o $@

ptx:		$(CU_PTX) 

clean:
		rm -f *.o vector-add vector-add-events
