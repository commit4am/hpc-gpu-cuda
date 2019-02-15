PROJ_BASE	:= .

INCLUDES	:= -I"$(PROJ_BASE)"
LIBS		:= 

CUDA_LIBS	:= $(LIBS) -L"$(CUDA_INSTALL_PATH)/lib64"

NVCCFLAGS	:= --ptxas-options=-v
ifneq ($(debug), 1)
	CFLAGS		:= -O3 -g0 -w
	NVCCFLAGS	+= -O3
else
	CFLAGS		:= -O0 -g3 -Wall
	NVCCFLAGS	+= -O0
endif

LDFLAGS         := -lm -lX11 -lpthread
CUDA_LDFLAGS	:= $(LDFLAGS) -lrt -lcudart

CC		:= g++
NVCC		:= nvcc
LINKER		:= g++

