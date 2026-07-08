# Complex Matrix Eigenvalue Determination via Iterative QR Decomposition

This repository provides an ANSI C implementation and theoretical performance analysis for computing the eigenvalues of complex-valued square matrices ($\mathbb{C}^{n \times n}$) using the classical iterative QR decomposition method based on the Gram-Schmidt orthogonalization process.

## Author
* Patnam Shariq Faraz Muhammed (EE24BTECH11049)

---

## Technical Overview
The eigenvalue problem seeks scalars $\lambda \in \mathbb{C}$ such that $Av = \lambda v$ for a non-zero vector $v$. This project extracts all eigenvalues by iteratively decomposing matrix $A_k$ into an orthogonal matrix $Q_k$ and an upper triangular matrix $R_k$ such that:

$$A_k = Q_k R_k$$

The matrix for the next iteration is formed by reversing the multiplication order:

$$A_{k+1} = R_k Q_k = Q_k^{-1} A_k Q_k$$

As $k \to \infty$, $A_k$ asymptotically converges to a Schur/Hessenberg form, isolating individual or $2 \times 2$ block diagonal segments along the principal diagonal from which the true complex eigenvalues are directly parsed.

---

## Features
* **Complex Data Support:** Full integration of native `<complex.h>` mathematical primitives to track real and imaginary components natively.
* **Gram-Schmidt Orthogonalization:** Robust programmatic implementation of standard column orthogonalization vectors to build precision orthogonal $Q$ baselines.
* **Dynamic Matrix Matrix Allocation:** Clean 2D array matrix allocations wrapped tightly into custom structure headers (`Matrix`) managing metadata dimensions dynamically.
* **$2 \times 2$ Sub-matrix Deflation Processing:** Explicit analytical solver using quadratic discriminant logic ($csqrt$) to correctly parse unreduced $2 \times 2$ diagonal blocks tracking paired complex-conjugate root pairs.
* **Performance Benchmark Telemetry:** Built-in `<time.h>` profiling clocks to capture pure wall-clock execution tracking tracking software throughput performance.

---

## Project Structure & Source Specifications

### Codebase Components
* `Matrix* CreateMatrix(int size)`: Dynamically allocates heap memories configuring pointers for rows and complex elements.
* `void FreeMatrix(Matrix *mat)`: Recursively frees allocated nested pointers preventing heap memory leaks.
* `void GramSchmidt(Matrix *A, Matrix *Q, Matrix *R)`: Projects matrix column dimensions into orthogonal matrices while computing magnitude scaling norms into the upper $R$ matrix.
* `void QR_Algorithm(Matrix *A, complex double *eigenvalues)`: Drives the top-level processing pipeline executing a hard ceiling of up to **1000 iterative loops** with dynamic shifts.

---

## Complexity Profile

| Parameter | Complexity | Metric Drivers |
| :--- | :--- | :--- |
| **Time Complexity** | $\mathcal{O}(n^3)$ | Dominant Gram-Schmidt vector loop chains & nested matrix multiplication iterations over 1000 maximum iterations. |
| **Space Complexity** | $\mathcal{O}(n^2)$ | Static overhead storage scaling for localized matrices $A$, $Q$, $R$, and intermediate matrix states. |

---

## Limitations
* **Numerical Instability:** Classical Gram-Schmidt (CGS) suffers from severe loss of orthogonality due to floating-point round-off errors on ill-conditioned matrices.
* **Slow Convergence:** Shift-less iterations cause poor convergence speed when eigenvalues are clustered closely in magnitude.
* **High Iteration Overhead:** Re-calculating a full dense $\mathcal{O}(n^3)$ decomposition every single iteration creates heavy execution bottlenecks.
* **Block Rigidity:** Deflation logic is restricted strictly to $1 \times 1$ and $2 \times 2$ isolated blocks.

---

## Further Improvements & Acceleration Methods
* **Upper Hessenberg Pre-conditioning:** Reduce matrix $A$ to an Upper Hessenberg form initially ($\mathcal{O}(n^3)$ once), dropping individual iteration costs from $\mathcal{O}(n^3)$ down to $\mathcal{O}(n^2)$.
* **Rayleigh/Wilkinson Shifts:** Introduce scalar updates ($A_k - \mu_k I$) to accelerate convergence from a slow linear rate up to a quadratic/cubic rate.
* **Householder Reflections or Givens Rotations:** Replace Gram-Schmidt with Givens rotations to protect numerical stability and zero out elements with $n-1$ simple coordinate rotations.
* **Contiguous 1D Array Layout:** Map the dynamic 2D array into a continuous 1D block (`size * size`) to maximize CPU spatial locality and eliminate cache misses.
* **SIMD & Loop Parallelization:** Inject OpenMP directives (`#pragma omp parallel for`) and vectorize vector inner products to distribute compute overhead across multi-core systems.

---

## Compilation and Execution

### Prerequisites
Ensure a modern standard C library engine is configured (e.g., GCC compiler framework) supporting standard C99 structures or later.

### Compilation Command
Compile the implementation file linking the system math libraries explicitly (`-lm`):

```bash
gcc -O2 main.c -o qr_eigen_solver -lm

