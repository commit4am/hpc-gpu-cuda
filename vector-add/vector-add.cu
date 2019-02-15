#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "timer.h"
#include <iostream>

#define none 0

using namespace std;

/* Utility function, use to do error checking.

   Use this function like this:

   checkCudaCall(cudaMalloc((void **) &deviceRGB, imgS * sizeof(color_t)));

   And to check the result of a kernel invocation:

   checkCudaCall(cudaGetLastError());
*/
static void checkCudaCall(cudaError_t result) {
    if (result != cudaSuccess) {
        cerr << "cuda error: " << cudaGetErrorString(result) << endl;
        exit(1);
    }
}


__global__ void vectorAddKernel(float* A, float* B, float* Result) {
// code here!
    int i = threadIdx.x + blockDim.x * blockIdx.x;
    Result[i] = A[i] + B[i];
}


void vectorAddCuda(int n, float* a, float* b, float* result) {
    int threadBlockSize = 512;

    // allocate the vectors on the GPU
    float* deviceA = NULL;
    checkCudaCall(cudaMalloc((void **) &deviceA, n * sizeof(float)));
    if (deviceA == NULL) {
        cout << "could not allocate memory!" << endl;
        return;
    }
    float* deviceB = NULL;
    checkCudaCall(cudaMalloc((void **) &deviceB, n * sizeof(float)));
    if (deviceB == NULL) {
        checkCudaCall(cudaFree(deviceA));
        cout << "could not allocate memory!" << endl;
        return;
    }
    float* deviceResult = NULL;
    checkCudaCall(cudaMalloc((void **) &deviceResult, n * sizeof(float)));
    if (deviceResult == NULL) {
        checkCudaCall(cudaFree(deviceA));
        checkCudaCall(cudaFree(deviceB));
        cout << "could not allocate memory!" << endl;
        return;
    }

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // copy the original vectors to the GPU
    checkCudaCall(cudaMemcpy(deviceA, a, n*sizeof(float), cudaMemcpyHostToDevice));
    checkCudaCall(cudaMemcpy(deviceB, b, n*sizeof(float), cudaMemcpyHostToDevice));

    // execute kernel
    cudaEventRecord(start, 0);
    vectorAddKernel<<<n/threadBlockSize, threadBlockSize>>>(deviceA, deviceB, deviceResult);
    cudaEventRecord(stop, 0);

    // check whether the kernel invocation was successful
    checkCudaCall(cudaGetLastError());

    // copy result back
    checkCudaCall(cudaMemcpy(result, deviceResult, n * sizeof(float), cudaMemcpyDeviceToHost));

    checkCudaCall(cudaFree(deviceA));
    checkCudaCall(cudaFree(deviceB));
    checkCudaCall(cudaFree(deviceResult));

    // print the time the kernel invocation took, without the copies!
    float elapsedTime;
    cudaEventElapsedTime(&elapsedTime, start, stop);
    
    cout << "kernel invocation took \t\t" << elapsedTime << " milliseconds" << endl;
}


int main(int argc, char* argv[]) {
    int n = 1000000;
    timer vectorAddTimer("vector add timer");
    float* a = new float[n];
    float* b = new float[n];
    float* result = new float[n];
    float* result_s = new float[n];

    // initialize the vectors.
    for(int i=0; i<n; i++) {
        a[i] = i;
        b[i] = i;
	result_s[i]=a[i]+b[i];
    }

    vectorAddTimer.start();
    vectorAddCuda(n, a, b, result);
    vectorAddTimer.stop();

    cout << "vector-add (CUDA, total): \t\t" << vectorAddTimer << endl;

    // verify the resuls
    for(int i=0; i<n; i++) {
        if(result[i] != result_s[i]) {
            cout << "error in results! Element " << i << " is " << result[i] << ", but should be " << (2*i) << endl;
            exit(1);
        }
    }
    cout << "results OK!" << endl;
            
    delete[] a;
    delete[] b;
    delete[] result;
    
    return 0;
}
