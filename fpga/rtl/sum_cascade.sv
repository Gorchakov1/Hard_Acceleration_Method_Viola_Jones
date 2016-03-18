/*
  Модуль сравнивает сумму прямоугольника с порогом домноженным на СКО.
  В зависимости от результата складываем с одним из alpha.

*/
`include "defs.vh"
module stage_sum (
  input               clk_i,
  input               rst_i,

  input               new_stage_i,
  
  input [31:0]        sum_cascade_i,
  input               sum_cascade_val_i,
 
  input [31:0]        thresholds_i,
  input [1:0]         thresholds_type_i,
  input               thresholds_val_i,
  
  input [31:0]        variance_norm_factor_i,

  output logic [31:0] stage_sum_o,
  output logic        stage_sum_val_o
);

logic [31:0] alpha [1:0];
logic left_val;
logic right_val;

assign left_val  = ( thresholds_type_i == `LEFT_VAL ) & thresholds_val_i;
assign right_val = ( thresholds_type_i == `RIGHT_VAL ) & thresholds_val_i;

// В OpenCV они почему то назывались alpha
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      begin
        alpha[0] <= '0;
        alpha[1] <= '0;
      end
    else
      begin
        if( right_val )
          alpha[0] <= thresholds_i;
        if( left_val  )
          alpha[1] <= thresholds_i;
      end
  end



logic [31:0] threshold;
logic [31:0] mult_result;

mult_fp mult(
  .clock  ( clk_i                  ),
  .aclr   ( rst_i                  ),
  .dataa  ( thresholds_i            ),
  .datab  ( variance_norm_factor_i ),
  .result ( mult_result            )
);
/*
 Требуется 4 тактов для вычисления произведения чисел 
 float и +1 относительно thresholds_val_i
*/
delay_signal #(
  .DATA_WIDTH  ( 1 ),
  .CLOCK_CNT   ( 5 )
) delay_threshold_val(
  .clk_i      ( clk_i                                                 ),
  .rst_i      ( rst_i                                                 ),

 .signal_i   ( ( thresholds_type_i == `THRESHOLD ) & thresholds_val_i ), 
 .signal_o   ( threshold_val                                          )
);

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      threshold <= '0;
    else
      begin
        if( threshold_val)
          threshold <= mult_result;
      end
  end

logic cond;

comp_fp comp(
  .clock ( clk_i         ),
  .aclr  ( rst_i         ),
  .dataa ( threshold      ),
  .datab ( sum_cascade_i ),
  .ageb  ( cond          )
);

logic [31:0] stage_sum;
logic [31:0] sum;

add_fp _sum(
  .clock  ( clk_i       ),
  .aclr   ( rst_i       ),
  .dataa  ( alpha[cond] ),
  .datab  ( stage_sum   ),
  .result ( sum         )
);
/*
  Требуется 7 тактов для сложения чисел float, 1 такт для сравнения
  и один такт т.к. относительно sum_cascade_val_i
*/
delay_signal #(
  .DATA_WIDTH  ( 1 ),
  .CLOCK_CNT   ( 9 )
) delay_stage_threshold_val(
  .clk_i      ( clk_i                    ),
  .rst_i      ( rst_i                    ),

  .signal_i   ( sum_cascade_val_i        ), 
  .signal_o   ( stage_sum_val            )
);

// Надо обнулять сумму, т.к. заново считаем stage_sum
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      stage_sum <= '0;
    else
      begin
        if( new_stage_i )
          stage_sum <= '0;
        else
          begin
            if( stage_sum_val )
              stage_sum <= sum;
          end
      end
  end

assign stage_sum_o = sum;
assign stage_sum_val_o = stage_sum_val;
/////////////////////////////
//always_comb 
  //if( stage_sum_val )
   // $display("stage sum %f", $bitstoshortreal( sum ));
endmodule
