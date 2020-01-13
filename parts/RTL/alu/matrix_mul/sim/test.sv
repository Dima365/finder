module test
#(
    // matrix A - N*M 
    parameter A_N = 2, // count of elem. in column 
    parameter A_M = 2, // count of elem. in row
    // matrix B - N*M
    parameter B_N = 2, // count of elem. in column
    parameter B_M = 2, // count of elem. in row
    // width of element in matrix
    parameter WIDTH = 16    
)
();
logic [A_M-1:0][A_N-1:0][WIDTH-1:0] matA_r;
logic [B_M-1:0][B_N-1:0][WIDTH-1:0] matB_r;
logic [A_M-1:0][A_N-1:0][WIDTH-1:0] matA_i;
logic [B_M-1:0][B_N-1:0][WIDTH-1:0] matB_i;

logic [B_M-1:0][A_N-1:0][WIDTH-1:0] res_r;
logic [B_M-1:0][A_N-1:0][WIDTH-1:0] res_i;

matrix_mul_imag
    #(
        .A_N    (A_N),
        .A_M    (A_M),
        .B_N    (B_N),
        .B_M    (B_M),
        .WIDTH  (WIDTH)
    )
matrix_mul_imag_i1
    (
        .*
    );

initial begin
    matA_r[0][0] = 0;
    matA_r[0][1] = 0;
    matA_r[1][0] = 0;
    matA_r[1][1] = 0;

    matB_r[0][0] = 0;
    matB_r[0][1] = 0;
    matB_r[1][0] = 0;
    matB_r[1][1] = 0;

    matA_i[0][0] = 0;
    matA_i[0][1] = 0;
    matA_i[1][0] = 0;
    matA_i[1][1] = 0;

    matB_i[0][0] = 0;
    matB_i[0][1] = 0;
    matB_i[1][0] = 0;
    matB_i[1][1] = 0;

    matA_r[0][0][WIDTH-1:WIDTH/2] = 2;
    matA_r[0][1][WIDTH-1:WIDTH/2] = 2;
    matA_r[1][0][WIDTH-1:WIDTH/2] = 2;
    matA_r[1][1][WIDTH-1:WIDTH/2] = 2;

    matB_r[0][0][WIDTH-1:WIDTH/2] = 2;
    matB_r[0][1][WIDTH-1:WIDTH/2] = 2;
    matB_r[1][0][WIDTH-1:WIDTH/2] = 2;
    matB_r[1][1][WIDTH-1:WIDTH/2] = 2;

    matA_i[0][0][WIDTH-1:WIDTH/2] = 2;
    matA_i[0][1][WIDTH-1:WIDTH/2] = 2;
    matA_i[1][0][WIDTH-1:WIDTH/2] = 2;
    matA_i[1][1][WIDTH-1:WIDTH/2] = 2;

    matB_i[0][0][WIDTH-1:WIDTH/2] = 2;
    matB_i[0][1][WIDTH-1:WIDTH/2] = 2;
    matB_i[1][0][WIDTH-1:WIDTH/2] = 2;
    matB_i[1][1][WIDTH-1:WIDTH/2] = 2;

    #1000 $stop;
    #1000 $stop;
end


endmodule