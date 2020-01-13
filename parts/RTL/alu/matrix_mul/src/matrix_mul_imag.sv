module matrix_mul_imag
#(
    // matrix A - M*N 
    parameter A_N = 8, // number column 
    parameter A_M = 8, // number line
    // matrix B - N*M
    parameter B_N = 8, // number colum
    parameter B_M = 8, // number line
    // width of element in matrix
    parameter WIDTH = 16  
)
(
    input  logic [A_M-1:0][A_N-1:0][WIDTH-1:0] matA_r,
    input  logic [B_M-1:0][B_N-1:0][WIDTH-1:0] matB_r,
    input  logic [A_M-1:0][A_N-1:0][WIDTH-1:0] matA_i,
    input  logic [B_M-1:0][B_N-1:0][WIDTH-1:0] matB_i,

    output logic [B_M-1:0][A_N-1:0][WIDTH-1:0] res_r ,
    output logic [B_M-1:0][A_N-1:0][WIDTH-1:0] res_i 
); 
// A_M and B_N have to be equal
logic [B_M-1:0][A_N-1:0][WIDTH-1:0] res_r1;
logic [B_M-1:0][A_N-1:0][WIDTH-1:0] res_r2;
logic [B_M-1:0][A_N-1:0][WIDTH-1:0] res_ri;
logic [B_M-1:0][A_N-1:0][WIDTH-1:0] res_ir;

matrix_mul
    #(
        .A_N    (A_N),
        .A_M    (A_M),
        .B_N    (B_N),
        .B_M    (B_M),
        .WIDTH  (WIDTH)
    )
matrix_mul_real
    (
        .imageA (1'b0),
        .imageB (1'b0),
        .matA   (matA_r),
        .matB   (matB_r),
        .res    (res_r1)
    );

matrix_mul
    #(
        .A_N    (A_N),
        .A_M    (A_M),
        .B_N    (B_N),
        .B_M    (B_M),
        .WIDTH  (WIDTH)
    )
matrix_mul_imag
    (
        .imageA (1'b1),
        .imageB (1'b1),
        .matA   (matA_i),
        .matB   (matB_i),
        .res    (res_r2)
    );

matrix_mul
    #(
        .A_N    (A_N),
        .A_M    (A_M),
        .B_N    (B_N),
        .B_M    (B_M),
        .WIDTH  (WIDTH)
    )
matrix_mul_ri
    (
        .imageA (1'b0),
        .imageB (1'b1),
        .matA   (matA_r),
        .matB   (matB_i),
        .res    (res_ri)
    );

matrix_mul
    #(
        .A_N    (A_N),
        .A_M    (A_M),
        .B_N    (B_N),
        .B_M    (B_M),
        .WIDTH  (WIDTH)
    )
matrix_mul_ir
    (
        .imageA (1'b1),
        .imageB (1'b0),
        .matA   (matA_i),
        .matB   (matB_r),
        .res    (res_ir)
    );

genvar i,j;
generate
    for(i = 0; i < A_M; i = i + 1)begin: ss
      for(j = 0; j < B_N; j = j + 1)begin: aa
        assign res_r[i][j] = res_r1[i][j] + res_r2[i][j];
        assign res_i[i][j] = res_ri[i][j] + res_ir[i][j];
      end: aa
    end: ss            
endgenerate

endmodule