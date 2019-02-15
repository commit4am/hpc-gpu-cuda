__global__ void vec_add_kernel(float *c, float *a, float *b, int n) {
    int i = threadIdx.x + blockDim.x * blockIdx.x;   // Oops! Something is not right here, please fix it!
    c[i] = a[i] + b[i];
}
