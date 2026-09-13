# CUDA / HPC

GPU implementations of five compute kernels, each paired with a sequential
reference, built for a high-performance computing course and run on a
SLURM-scheduled GPU cluster.

Every directory holds the same three things: a CUDA implementation, a CPU
version doing identical work, and a timing harness that measures both. The
point throughout is the comparison — a kernel that produces the right answer
but never beats the CPU has taught you nothing.

## What's here

| Directory | Problem | The interesting part |
|---|---|---|
| `conv/` | 2D image convolution | Shared-memory tiling with halo regions, against a naive global-memory kernel |
| `crypto/` | Caesar cipher encrypt/decrypt | Embarrassingly parallel throughput over multi-megabyte inputs |
| `vector-add/` | Vector addition | Baseline kernel plus a `cudaEvent`-instrumented variant |
| `vector-add-streams/` | Vector addition, overlapped | Chunked async transfers pipelined across CUDA streams |
| `vector-transform/` | Elementwise transform | Memory-bound kernel — bandwidth, not arithmetic, is the limit |

## How it works

**Tiled convolution with halo handling** (`conv/convolution.cu`)

The naive kernel reads every input pixel from global memory once per filter
tap. For a 3×3 filter that is nine global reads per output pixel, eight of
them redundant with a neighbouring thread's reads.

The optimised kernel stages a tile in shared memory first:

```c
#define block_size_x 32
#define block_size_y 16
#define border_height ((filter_height/2)*2)
#define border_width  ((filter_width/2)*2)

__shared__ float sh_input[block_size_y + border_height]
                         [block_size_x + border_width];
```

The `border_*` padding is the halo — the ring of pixels outside the block's
own output region that its threads still need to read, because a convolution
window centred on an edge pixel extends past the tile. Sizing the shared array
to `block + border` rather than `block` is what makes the boundary threads
correct instead of reading garbage, and it is the part that is easy to get
subtly wrong. Both kernels are kept in the file so the two can be timed
against each other rather than one replacing the other.

**Stream overlap** (`vector-add-streams/vector-add-streams.cu`)

A single-stream CUDA program serialises three phases: copy host→device, run
the kernel, copy device→host. The GPU sits idle during both copies and the
PCIe bus sits idle during the kernel.

This version splits the input into `n / nStreams` chunks and issues
`cudaMemcpyAsync` → kernel → `cudaMemcpyAsync` per chunk on its own stream, so
chunk *i*'s kernel runs while chunk *i+1* is still being copied across.
`nStreams` is a tunable at the top of the file, currently 4.

## Results

Not published here. The timing harness prints per-kernel milliseconds at
runtime —

```c
printf("convolution_kernel took %.3f ms\n", time);
```

— but the measurements were never committed, and reproducing them needs the
GPU cluster the code targets. Rather than quote numbers from memory, the
comparison is left to whoever runs it: every directory builds both
implementations and times both, so a single `make && srun` produces the
speedup on your own hardware.

## Run it

Each directory is self-contained:

```bash
cd conv
make
srun ./convolution          # or: sbatch myjob.gpu
```

`myjob.gpu` is a SLURM batch script targeting a short GPU partition. On a
workstation with a CUDA device, `make && ./convolution` works directly.

Requires the CUDA toolkit (`nvcc`) and a compute-capable NVIDIA GPU.

## Stack

CUDA C/C++, `nvcc`, SLURM, GNU Make.
