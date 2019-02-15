#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <iostream>
#include "timer.h"

using namespace std;

int vectorAddSeq(int n, float* a, float* b, float* result) {
  int i; 

  timer sequentialTime = timer("Sequential");
  
  sequentialTime.start();
  for (i=0; i<n; i++) {
	result[i] = a[i]+b[i];
  }
  sequentialTime.stop();
  
  cout << "vector-add (sequential): \t\t" << sequentialTime << endl;

}

int main(int argc, char* argv[]) {
    int n = 655360;
    float* a = new float[n];
    float* b = new float[n];
    float* result = new float[n];
    float* result_s = new float[n];

    if (argc > 1) n = atoi(argv[1]);

    cout << "Adding two vectors of " << n << " integer elements." << endl;
    // initialize the vectors.
    for(int i=0; i<n; i++) {
        a[i] = i;
        b[i] = i;
    }

    vectorAddSeq(n, a, b, result_s);
    
    delete[] a;
    delete[] b;
    delete[] result;
    
    return 0;
}
