#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <complex.h>
#include <string.h>
#include <time.h>

typedef struct {
    int size;
    complex double **matrix;
} Matrix;

Matrix* CreateMatrix(int size) {
    Matrix *mat = (Matrix*)malloc(sizeof(Matrix));
    mat->size = size;
    mat->matrix = (complex double**)malloc(size * sizeof(complex double*));
    for (int i = 0; i < size; i++) {
        mat->matrix[i] = (complex double*)malloc(size * sizeof(complex double));
    }
    return mat;
}

void FreeMatrix(Matrix *mat) {
    for (int i = 0; i < mat->size; i++) {
        free(mat->matrix[i]);
    }
    free(mat->matrix);
    free(mat);
}

void MatrixMultiply(Matrix *A, Matrix *B, Matrix *C) {
    int size = A->size;
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            C->matrix[i][j] = 0.0 + 0.0 * I;
            for (int k = 0; k < size; k++) {
                C->matrix[i][j] += A->matrix[i][k] * B->matrix[k][j];
            }
        }
    }
}

void GramSchmidtProcess(Matrix *A, Matrix *Q, Matrix *R) {
    int size = A->size;
    for (int j = 0; j < size; j++) {
        for (int i = 0; i < size; i++) {
            Q->matrix[i][j] = A->matrix[i][j];
        }
        for (int m = 0; m < j; m++) {
            complex double dot_product = 0.0 + 0.0 * I;
            for (int i = 0; i < size; i++) {
                dot_product += conj(Q->matrix[i][m]) * Q->matrix[i][j];
            }
            R->matrix[m][j] = dot_product;
            for (int i = 0; i < size; i++) {
                Q->matrix[i][j] -= R->matrix[m][j] * Q->matrix[i][m];
            }
        }
        R->matrix[j][j] = 0.0;
        for (int i = 0; i < size; i++) {
            R->matrix[j][j] += creal(Q->matrix[i][j]) * creal(Q->matrix[i][j]) + cimag(Q->matrix[i][j]) * cimag(Q->matrix[i][j]);
        }
        R->matrix[j][j] = sqrt(R->matrix[j][j]);
        for (int i = 0; i < size; i++) {
            Q->matrix[i][j] /= R->matrix[j][j];
        }
    }
}

void QRDecompose(Matrix *A, complex double *eigenvalues) {
    int size = A->size;
    Matrix *Q = CreateMatrix(size);
    Matrix *R = CreateMatrix(size);
    Matrix *temp = CreateMatrix(size);
    for (int n = 0; n < 1000; n++) {
        GramSchmidtProcess(A, Q, R);
        MatrixMultiply(R, Q, temp);
        for (int i = 0; i < size; i++) {
            for (int j = 0; j < size; j++) {
                A->matrix[i][j] = temp->matrix[i][j];
            }
        }
    }
    int idx = 0;
    while (idx < size) {
        if ((idx < size - 1) && (cabs(A->matrix[idx + 1][idx]) > 1e-10)) {
            complex double a = A->matrix[idx][idx];
            complex double b = A->matrix[idx + 1][idx];
            complex double c = A->matrix[idx][idx + 1];
            complex double d = A->matrix[idx + 1][idx + 1];
            complex double trace = -(a + d);
            complex double determinant = (a * d - b * c);
            eigenvalues[idx] = (-trace + csqrt(trace * trace - 4.0 * determinant)) / 2.0;
            eigenvalues[idx + 1] = (-trace - csqrt(trace * trace - 4.0 * determinant)) / 2.0;
            A->matrix[idx + 1][idx] = 0;
            idx += 2;
        } else {
            eigenvalues[idx] = A->matrix[idx][idx];
            idx++;
        }
    }
    FreeMatrix(Q);
    FreeMatrix(R);
    FreeMatrix(temp);
}

int main() {
    int size;
    printf("Enter the size of matrix: ");
    scanf("%d", &size);
    if (size <= 0) {
        printf("Matrix size must be positive.\n");
        return 0;
    }
    Matrix *matrix = CreateMatrix(size);
    printf("Enter the elements row-wise (real imag): \n");
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            double real, imag;
            scanf("%lf %lf", &real, &imag);
            matrix->matrix[i][j] = real + imag * I;
        }
    }
    complex double *eigenvalues = (complex double*)malloc(size * sizeof(complex double));
    clock_t start_time = clock();
    QRDecompose(matrix, eigenvalues);
    clock_t end_time = clock();
    printf("Eigenvalues:\n");
    for (int i = 0; i < size; i++) {
        printf("%.10lf + %.10lfi\n", creal(eigenvalues[i]), cimag(eigenvalues[i]));
    }
    printf("Duration of code run: %.10f seconds\n", (double)(end_time - start_time) / CLOCKS_PER_SEC);
    FreeMatrix(matrix);
    free(eigenvalues);
    return 0;
}

