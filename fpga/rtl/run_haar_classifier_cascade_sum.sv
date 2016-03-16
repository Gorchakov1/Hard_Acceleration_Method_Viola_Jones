module run_haar_classifier_cascade_sum 
#(
  ADDR_WIDTH_II        = $clog2( 21 * 21 ),
  NUM_WORDS_ROM        = 10697,
  ADDR_WIDTH_ROM       = $clog2( NUM_WORDS_ROM ),
  STAGE_CLASSIFIER_CNT = 22
)
(
  input                          clk_i,
  input                          rst_i,
                                 
  input                          start_i,

  input [ADDR_WIDTH_II-1:0]      ii_addr_wr_i,
  input [31:0]                   ii_data_wr_i,
  input                          ii_val_wr_i,
                                 
  input [31:0]                   variance_norm_factor_i,
                                 
  output logic                   done_o,
  output logic                   result_o


);

logic                      break_s;
logic                      next_stage;
logic                      pause;

logic                      stage_val;
logic [ADDR_WIDTH_ROM-1:0] rom_addr;
logic                      rom_val;

logic [31:0]               rom_data;

logic                      stage_last;

rom_control #(
  .ADDR_WIDTH           ( ADDR_WIDTH_ROM            ), 
  .STAGE_CLASSIFIER_CNT ( STAGE_CLASSIFIER_CNT      ),
  .LAST_ADDR_ROM        ( NUM_WORDS_ROM - 1         )
) rom_ctrl (                                        
  .clk_i                ( clk_i                     ),
  .rst_i                ( rst_i                     ),
                                                   
  .break_i              ( break_s                   ),
  .next_stage_i         ( next_stage                ),
  .wait_i               ( pause                     ),
                                                   
  .stage_last_o         ( stage_last                ),
  .stage_val_o          ( stage_val                 ),
  .rom_addr_o           ( rom_addr                  ),
  .rom_val_o            ( rom_val                   )
);                                                

rom #(
  .INIT_FILE            ( "classifier.mif"          ),
  .DATA_WIDTH           ( 32                        ),
  .NUM_WORDS            ( 10697                     )  
) rom_classifier (                               
  .clock                ( clk_i                     ),
  .address              ( rom_addr                  ),
  .q                    ( rom_data                  )
                                                
);                                               
                                                 
logic                     ii_val;                             
logic [31:0]              ii_data;                            
logic [ADDR_WIDTH_II-1:0] ii_addr;
logic [3:0]               weight;
logic [3:0]               num_point;
logic [31:0]              sum_cascade;
logic                     sum_cascade_val;

logic [31:0]              thresholds;
logic [1:0]               thresholds_type;
logic                     thresholds_val;

logic [31:0]              stage_threshold;
logic                     stage_threshold_val;
word_parser #(
  .ADDR_WIDTH            ( ADDR_WIDTH_II             )
                                                   
) word (                                           
  .clk_i                 ( clk_i                     ),
  .rst_i                 ( rst_i                     ),
                                                   
  .rom_data_i            ( rom_data                  ),
  .stage_threshold_val_i ( stage_val                 ),
  .rom_val_i             ( rom_val                   ),
  .last_stage_i          ( stage_last                ),
                                                   
  .stage_threshold_o     ( stage_threshold            ),
  .stage_threshold_val_o ( stage_threshold_val        ),

  .thresholds_o          ( thresholds                 ),
  .thresholds_type_o     ( thresholds_type            ),
  .thresholds_val_o      ( thresholds_val             ),
                                                 
  .addr_ii_o             ( ii_addr                   ),
  .val_ii_o              ( ii_val                    ),
  .weight_o              ( weight                    ),
                                                
  .num_point_o           ( num_point                 ),
                                                 
  .wait_o                ( pause                     )
);                                               

ram #(
  .ADDR_WIDTH            ( ADDR_WIDTH_II             ),
  .DATA_WIDTH            ( 32                        )
)ii(                                               
  .clk                   ( clk_i                     ),
                                                   
   .write_addr           ( ii_addr_wr_i              ),
   .we                   ( ii_val_wr_i               ),
	 .data                 ( ii_data_wr_i              ),
                                                    
  .read_addr             ( ii_addr                   ),
  .q                     ( ii_data                   )
                                                   
);
logic [31:0] stage_sum_s;
logic        stage_sum_val;
calk_sum cs(
  .clk_i									( clk_i                   ),
  .rst_i									( rst_i                   ),
                                                  
  .ii_val_i								( ii_val                  ), 
  .ii_data_i							( ii_data                 ),
                                                  
  .weight_i								( weight                  ),
                                                 
  .num_point_i						( num_point               ),
                                                  
  .sum_cascade_o					( sum_cascade             ),
  .sum_cascade_val_o			( sum_cascade_val         )
);
stage_sum ss(
  .clk_i									( clk_i                   ),
  .rst_i									( rst_i                   ),
  .new_stage_i						( next_stage | done_o     ),
  
  .sum_cascade_i					( sum_cascade             ),
  .sum_cascade_val_i			( sum_cascade_val         ), 

  .thresholds_i						( thresholds               ),
  .thresholds_type_i		  ( thresholds_type          ),
  .thresholds_val_i				( thresholds_val           ),
  
  .variance_norm_factor_i ( variance_norm_factor_i  ),

  .stage_sum_o            ( stage_sum_s             ), 
  .stage_sum_val_o        ( stage_sum_val           )
);

result_classifier_control ctrl(
  .clk_i                  ( clk_i                   ),
  .rst_i                  ( rst_i                   ), 
                                                    
  .start_i                ( start_i                 ),
  .done_o                 ( done_o                  ),
  .result_o               ( result_o                ),
                                                    
  .stage_sum_i            ( stage_sum_s             ),
  .stage_sum_val_i        ( stage_sum_val           ),
                                                    
  .stage_threshold_i      ( stage_threshold          ), 
  .stage_threshold_val_i  ( stage_threshold_val      ),
                                                    
  .stage_last_i           ( stage_last              ),
  .next_stage_o           ( next_stage              ),
  .break_o                ( break_s                 )           
);                        

endmodule
