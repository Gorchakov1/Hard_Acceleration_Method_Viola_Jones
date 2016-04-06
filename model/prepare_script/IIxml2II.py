import cv2

img = cv2.cv.Load("II.xml")
II = list()

x = 0#12#105
y = 0#7#57

p0 = 960
p1 = 69247
p2 = 9665
p3 = 7091


offset = 21

for i in range(img.rows ):
 # if( i >= y and i < y + offset ):
  for j in range( img.cols):
    if( p0 == int ( cv2.cv.Get2D( img,i,j )[0] ) ):
      print 'p0 ',i,j
    if( p1 == int ( cv2.cv.Get2D( img,i,j )[0] ) ):
      print 'p1 ', i,j
    if( p2 == int ( cv2.cv.Get2D( img,i,j )[0] ) ):
      print 'p2 ', i,j
    if( p3 == int ( cv2.cv.Get2D( img,i,j )[0] ) ):
      print 'p3 ', i,j

  #    if( j>= x and j < x + offset ):
#        print i,j
 #       II.append( [ int ( cv2.cv.Get2D( img,i,j )[0] ), i , j ] )





#f = open('II2', 'w')
#for data in II:
#  f.write( "%i\n" % data[0] )
#  print data
#f.close()
  
