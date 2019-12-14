module matrix_mul 
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
    input  logic imageA,
    input  logic imageB,

    input  logic [A_M-1:0][A_N-1:0][WIDTH-1:0] matA,
    input  logic [B_M-1:0][B_N-1:0][WIDTH-1:0] matB,
    output logic [B_M-1:0][A_N-1:0][WIDTH-1:0] res 
);
// A_M and B_N have to be equal
logic [A_M-1:0][B_N-1:0][B_M-1:0][2*WIDTH-1:0] mul_matrix;
logic [A_M-1:0][A_N-1:0][WIDTH-1:0]  matA_inside;
logic [B_M-1:0][B_N-1:0][WIDTH-1:0]  matB_inside;

logic [A_M-1:0][B_N-1:0][B_M-1:0] sign_matrix;
logic [A_M-1:0][B_N-1:0][B_M-1:1][2*WIDTH-1:0] sum_matrix;

logic image;

assign image = imageA && imageB; // for invert sign if both image

genvar i,j,k;
generate
    for(i = 0; i < A_M; i = i + 1)begin:ss1
      for(j = 0; j < A_N; j = j + 1)begin:ss2
        assign matA_inside[i][j] = ~matA[i][j] + 1;
      end
    end


    for(i = 0; i < B_M; i = i + 1)begin:ss3
      for(j = 0; j < B_N; j = j + 1)begin:ss4
        assign matB_inside[i][j] = ~matB[i][j] + 1;
      end:ss4
    end:ss3


    for(i = 0; i < A_M; i = i + 1)begin:ss5
      for( j = 0; j < B_N; j = j + 1)begin:ss6
        for(k = 0; k < B_M; k = k + 1)begin:ss7

          assign mul_matrix[i][j][k]  = (sign_matrix[i][j][k]) ?
                                        ~(matA_inside[i][k] * matB_inside[k][j]) + 1 :
                                          matA_inside[i][k] * matB_inside[k][j];

          always_comb
            if(image && (matA_inside[i][k][WIDTH-1] != matB_inside[k][j][WIDTH-1]))
                sign_matrix[i][j][k] = 1'b0;

            else if(matA_inside[i][k][WIDTH-1] != matB_inside[k][j][WIDTH-1])
                sign_matrix[i][j][k] = 1'b1;

            else if(image && matA_inside[i][k][WIDTH-1] && matB_inside[k][j][WIDTH-1])
                sign_matrix[i][j][k] = 1'b1;

            else if(matA_inside[i][k][WIDTH-1] && matB_inside[k][j][WIDTH-1])
                sign_matrix[i][j][k] = 1'b0;

            else if(image)
                sign_matrix[i][j][k] = 1'b1;

            else
                sign_matrix[i][j][k] = 1'b0;
//          assign sign_matrix[i][j][k] = (matA_inside[i][k][WIDTH-1] || 
//                                         matB_inside[k][j][WIDTH-1] ) ? 1'b1 : 1'b0;

        end:ss7        
      end:ss6
    end:ss5

    for(i = 0; i < A_M; i = i + 1)begin:aa1
      for(j = 0; j < B_N; j = j + 1)begin:aa2
        for(k = 1; k < B_M; k = k + 1)begin:aa10
          if(k == 1)begin:aa3
            assign sum_matrix[i][j][k] = mul_matrix[i][j][k] + mul_matrix[i][j][k-1];
          end:aa3
          else begin:aa4
            assign sum_matrix[i][j][k] = sum_matrix[i][j][k-1] + mul_matrix[i][j][k];
          end:aa4
        end:aa10
      end:aa2
    end:aa1


    for(i = 0; i < A_M; i = i + 1)begin:ss8
      for(j = 0; j < B_N; j = j + 1)begin:ss9  
        assign res[i][j] = sum_matrix[i][j][B_M-1][WIDTH+7:WIDTH/2];        
      end:ss9
    end:ss8


endgenerate


endmodule