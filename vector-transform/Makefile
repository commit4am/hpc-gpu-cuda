NVCC		= nvcc
CC		= g++
#CU_FLAGS	= -O3 -g -deviceemu
CU_FLAGS	= -O3 -g --ptxas-options=-v
CC_FLAGS	= -O3 -m64 -Wall

CU_SOURCES	= vector-transform.cu
CC_SOURCES	= timer.cc

CU_OBJECTS	= $(CU_SOURCES:%.cu=%.o)
CU_PTX		= $(CU_SOURCES:%.cu=%.ptx)
CC_OBJECTS	= $(CC_SOURCES:%.cc=%.o)

%.o:		%.cu
		$(NVCC) $(CU_FLAGS) -c $< -o $@

%.o:		%.cc
		$(CC) $(CC_FLAGS) -c $< -o $@

%.ptx:		%.cu
		$(NVCC) $(CU_FLAGS) --ptx $< -o $@

vector-transform:	$(CU_OBJECTS) $(CC_OBJECTS)
		$(NVCC) $^ -o $@

ptx:		$(CU_PTX) 

clean:
		rm -f *.o vector-transform
