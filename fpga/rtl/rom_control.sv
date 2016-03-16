
module rom_control #(
  ADDR_WIDTH           = 15,
  STAGE_CLASSIFIER_CNT = 22,
  LAST_ADDR_ROM        = 1155 
)

(
  input                           clk_i,
  input                           rst_i,

  input                           break_i,
  input                           next_stage_i,

  input                           wait_i,
 
  output logic                    stage_last_o,
  output logic                    stage_val_o,
  output logic [ADDR_WIDTH - 1:0] rom_addr_o,
  output logic                    rom_val_o
);

logic [ADDR_WIDTH - 1:0] addr_stage_classifier [STAGE_CLASSIFIER_CNT - 1:0]; 

initial
  begin
    #0.0
    $readmemb( "threshold_addr.txt", addr_stage_classifier );
  end

logic equal_addr;
logic [ADDR_WIDTH - 1:0] rom_addr;
logic [4:0] num_stage_classifier;
logic next_addr;

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      next_addr <= 1'b0;
    else
      next_addr = ( ~( wait_i | equal_addr ) | ( equal_addr &  next_stage_i ) ) & ~break_i;
  end

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      rom_addr <= '0;
    else
      begin
        if( break_i )
          rom_addr <= '0;
        else
          rom_addr <=( next_addr ) ? rom_addr + 1'b1 : rom_addr;
      end
  end

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      num_stage_classifier <= '0;
    else
      begin
        if( next_stage_i )
          num_stage_classifier <= num_stage_classifier + 1'b1;
        if( break_i )
          num_stage_classifier <= '0;  
      end
  end
   
logic stage_val;
assign equal_addr = ( rom_addr == addr_stage_classifier[num_stage_classifier] );
always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      stage_val <= 1'b0;
    else
      begin
        if( equal_addr && !next_stage_i )
          stage_val <= 1'b1;
        else
          stage_val <= 1'b0;
      end
  end

assign stage_val_o = stage_val && !next_stage_i && !break_i;

assign rom_val_o    = next_addr && !stage_val; 
assign stage_last_o = ( rom_addr == LAST_ADDR_ROM ) && stage_val_o; 
assign rom_addr_o   = rom_addr;
endmodule
