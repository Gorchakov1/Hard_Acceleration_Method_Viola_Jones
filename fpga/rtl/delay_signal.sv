module delay_signal #(
  DATA_WIDTH = 1,
  CLOCK_CNT = 1
)
(
  input                        clk_i,
  input                        rst_i,
  
  input        [DATA_WIDTH-1:0] signal_i,
  output logic [DATA_WIDTH-1:0] signal_o
);
logic [DATA_WIDTH-1:0] signal [CLOCK_CNT-1:0];

genvar g;
generate

  for( g = 0; g < CLOCK_CNT; g++ )
     begin : gen_delay
       always_ff @( posedge clk_i or posedge rst_i )
          begin 
            if( rst_i )
              signal[g] <= '0;
            else

              if( g == 0 )
                begin
                  signal[g] <= signal_i;
                end
              else
                begin
                 signal[g] <= signal[g-1];
                end

          end
     end

endgenerate

assign signal_o = signal[CLOCK_CNT-1];
endmodule
