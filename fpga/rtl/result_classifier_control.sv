/*
  Модуль сравнивает stage_sum с порогом.
  Если проходит, то считаем дальше.
  Если нет, то сообщаем, что закончили и сбрасываем остальные модули
  и ждем когда придет команда опять считат
  Если нет, то сообщаем, что закончили и сбрасываем остальные модули
  и ждем когда придет команда опять считать.
*/
module result_classifier_control(
  input clk_i,
  input rst_i,

  input        start_i,
  output logic done_o,
  output logic result_o,

  input [31:0] stage_sum_i,
  input        stage_sum_val_i,
   
  input [31:0] stage_threshold_i,
  input        stage_threshold_val_i,

  input        stage_last_i,
  output logic next_stage_o,
  output logic break_o
);

logic [31:0] stage_threshold;
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      stage_threshold <= '0;
    else
      begin
        if( stage_threshold_val_i )
          stage_threshold <= stage_threshold_i;
      end
  end

logic [1:0] ready_compare;
/*
  ready_compare[0] - указывает, что пришел stage_threshold
  ready_compare[1] - указывает, что результат сложения валиден, когда
  уже есть stage_treshold. Это позволяет отбросить промежуточные 
  вычисления stage_sum.
*/
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      ready_compare <= 2'b00;
    else
      begin
        if( stage_threshold_val_i )
          ready_compare[0] <= 1'b1;
        if( stage_sum_val_i && ready_compare[0] )
          ready_compare[1] <= 1'b1;
        if( done_o || next_stage_o || break_o )
          ready_compare <= 2'b00; 
      end
  end

logic result;
/*
  Сравниваем stage_sum c порогом
*/
comp_fp comp(
  .clock ( clk_i            ),
  .aclr  ( rst_i            ),
  .dataa ( stage_threshold  ),
  .datab ( stage_sum_i      ),
  .ageb  ( result           )
);

logic pause;
logic done_stage;

always_ff@( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      pause <= 1'b1;
    else
      begin
        if( start_i )
          pause <= 1'b0;
        if( done_o )
          pause <= 1'b1;
      end
  end

assign break_o      = pause;
assign done_stage   = &ready_compare;
assign next_stage_o = !stage_last_i & done_stage; 
assign done_o       = ( stage_last_i || result ) & done_stage;
assign result_o     = result;

/////////////////////////////////
always_comb
  begin
    if( stage_threshold_val_i && stage_sum_val_i )
      $display( "stage_sum %f", $bitstoshortreal( stage_sum_i) );
    if( next_stage_o )
      $display("###Next stage###");
  end

endmodule 
