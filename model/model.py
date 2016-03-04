from bitstring import BitArray
def read_mif( fn ):
  rom_classifier = list()
  f = open( fn, 'r' )
  lines = f.readlines()
  for addr in range( 5, len(lines) -1 ):
    line = lines[addr].split(':')[1]
    rom_classifier.append( line[:len(line)-2] )
  f.close()
  return rom_classifier 

def parse_str_rom( string, addr, addr_stage_treshold, num_tree_addr ):
  num_tree_new = num_tree_addr
  if( addr == addr_stage_treshold ):
    type_str = 'stage_treshold'
    num_tree_new = 0
    num_tree_addr = 6
  
  if( num_tree_addr == 0 ):
    type_str = 'rect0'
    num_tree_new = 1
  
  if( num_tree_addr == 1 ):
    type_str = 'rect1'
    num_tree_new = 2
  
  if( num_tree_addr == 2 ):
    type_str =  'feature_treshold'
    num_tree_new = 3
  
  if( num_tree_addr == 3 ):
    type_str = 'left_val'
    num_tree_new = 4
  
  if( num_tree_addr == 4 ):
    type_str = 'right_val'
    num_tree_new = 0
  return num_tree_new, type_str

def read_file( fn ):
  f = open( fn, 'r' )
  treshold_addr = list()
  lines = f.readlines()
  for line in lines:
    treshold_addr.append( int( line ))
  return treshold_addr

def parse_rect( string ):
  rect1_x = int( string[0:6], 2   )
  rect1_y = int( string[6:11], 2  )
  rect1_w = int( string[11:16], 2 )
  rect1_h = int( string[16:21], 2 )

  rect2_x = int( string[21:26], 2 )
  rect2_y = int( string[26:31], 2 )
  rect2_w = int( string[31:36], 2 )
  rect2_h = int( string[36:41], 2 )
  rect2_weight = int( string[41:43], 2 )

  rect3_x = int( string[43:48], 2 )
  rect3_y = int( string[48:53], 2 )
  rect3_w = int( string[53:58], 2 )
  rect3_h = int( string[58:63], 2 )
  rect3_weight = int( string[63:], 2 )
  return [ [rect1_x, rect1_y, rect1_w, rect1_h, -1 ], [ rect2_x, rect2_y, rect2_w, rect2_h, rect2_weight ], [ rect3_x, rect3_y, rect3_w, rect3_h, rect3_weight ] ]


fn_mif = "classifier.mif"
fn_treshold_addr = "treshold_addr"
fn_ii = 'II'
variance = 14.401331




rom_classifier = list()
rom_classifier = read_mif( fn_mif )
num_stage_treshold = 0
num_tree_addr = 0
sum_feature = 0
addr_stage_treshold = read_file( fn_treshold_addr )
ii = read_file( fn_ii )
for rom_addr, classifier in enumerate( rom_classifier ):
  num_tree_addr, type_str = parse_str_rom( classifier, rom_addr, addr_stage_treshold[num_stage_treshold] - 1, num_tree_addr ) 
  if( type_str == 'rect0' ):
    rects = classifier
    continue
  
  if( type_str == 'rect1' ):
    rects = parse_rect( rects + classifier[1:] )
    continue

  if( type_str == 'feature_treshold' ):
    feature_treshold = BitArray( bin = classifier )
    continue
  if( type_str == 'left_val' ):
    left_val = BitArray( bin = classifier )
    continue
  if( type_str == 'right_val' ):
    right_val = BitArray( bin = classifier )
    
    sum_ii = 0
    for rect in rects:
      ii_addr0 = rect[1] * 21 + rect[0]
      ii_addr1 = ( rect[1] + rect[3] ) * 21  + rect[0]   
      ii_addr2 = rect[1] * 21 + rect[0] + rect[2]
      ii_addr3 = ( rect[1] + rect[3] ) * 21  + rect[0] + rect[2]
      weight = rect[4]
      weight = float( weight )* ( 1.0/( 18 * 18 ) )
      sum_rect =( ii[ii_addr0] - ii[ii_addr1] - ii[ii_addr2] + ii[ii_addr3] )
      sum_ii = sum_ii + sum_rect * weight
   
    if( sum_ii <= ( feature_treshold.float * variance ) ):
      sum_feature = sum_feature + left_val.float
    else:
      sum_feature = sum_feature + right_val.float
    
    continue

  if( type_str == 'stage_treshold' ):
    stage_treshold = BitArray( bin = classifier )
    num_stage_treshold = num_stage_treshold + 1
    
    print 'Sum_Cascade      ', sum_ii
    print 'Sum_Feature      ', sum_feature
    print "Stage_Treshold   ", stage_treshold.float
    if( stage_treshold.float > sum_feature ):
      print "Number Cascade   ", num_stage_treshold
      break
    else:
      sum_feature = 0
      continue
print "Face detect done"
