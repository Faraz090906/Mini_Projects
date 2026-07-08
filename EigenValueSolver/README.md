# Complex Matrix Eigenvalue Determination via Iterative QR Decomposition

This repository provides an ANSI C implementation and theoretical performance analysis for computing the eigenvalues of complex-valued square matrices ($\mathbb{C}^{n \times n}$) using the classical iterative QR decomposition method based on the Gram-Schmidt orthogonalization process.

## Author
* **Student:** Patnam Shariq Faraz Muhammed (EE24BTECH11049)
* **Institution:** Indian Institute of Technology Hyderabad (IITH)
* **Department:** Department of Electrical Engineering
* **Course:** Software Assignment (EE1010 Framework)

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

## Compilation and Execution

### Prerequisites
Ensure a modern standard C library engine is configured (e.g., GCC compiler framework) supporting standard C99 structures or later.

### Compilation Command
Compile the implementation file linking the system math libraries explicitly (`-lm`):

```bash
gcc -O2 main.c -o qr_eigen_solver -lm