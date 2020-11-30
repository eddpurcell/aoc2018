USING: kernel accessors math math.order sequences vectors arrays sets sorting io ;
USE: prettyprint

IN: particle-messages

TUPLE: particle { x integer } { y integer } { dx integer read-only } { dy integer read-only } ;
: <particle> ( x y dx dy -- particle ) particle boa ;
: move ( particle -- ) dup x>> over dx>> + >>x dup y>> over dy>> + swap y<< ;

: particle-xs ( particles -- xs ) [ x>> ] map members ;
: particle-ys ( particles -- ys ) [ y>> ] map members ;
: particles-in-row ( y particles -- particles' ) [ y>> over = ] filter nip ;
: particles-in-col ( x particles -- particles' ) [ x>> over = ] filter nip ;
: sort-by-x ( particles -- particles' ) [ [ x>> ] dip x>> <=> ] sort ;
: sort-by-y ( particles -- particles' ) [ [ y>> ] dip y>> <=> ] sort ;
: group-particles-x ( particles -- seq-particles ) 
  sort-by-x unclip 1vector 1vector swap [ 
    over last last x>> 1 + over x>> =
    [ over last push ]
    [ 1vector over push ]
    if
  ] each ;
: group-particles-y ( particles -- seq-particles ) 
  sort-by-y unclip 1vector 1vector swap [ 
    over last last y>> 1 + over y>> =
    [ over last push ]
    [ 1vector over push ]
    if
  ] each ;
: particles-in-hline? ( n particles -- ? ) dup particle-ys [ over particles-in-row group-particles-x [ length ] map supremum pick >= ] filter length 0 > 2nip ;
: particles-in-vline? ( n particles -- ? ) dup particle-xs [ over particles-in-col group-particles-y [ length ] map supremum pick >= ] filter length 0 > 2nip ;

: minmax ( seq -- min max ) dup infimum swap supremum ;
: print-particles ( particles -- ) dup particle-ys minmax over - 1 + <iota> [ over + ] map nip [
    over particles-in-row particle-xs 
    over particle-xs minmax over - 1 + <iota> [ over + ] map nip 
    [
      over in? [ "#" write ] [ "." write ] if
    ] each drop
    "\n" write
  ] each drop ;

{ }
9 1 0 2  <particle> 1array append
7 0 -1 0  <particle> 1array append
3 -2 -1 1  <particle> 1array append
6 10 -2 -1  <particle> 1array append
2 -4 2 2  <particle> 1array append
-6 10 2 -2  <particle> 1array append
1 8 1 -1  <particle> 1array append
1 7 1 0  <particle> 1array append
-3 11 1 -2  <particle> 1array append
7 6 -1 -1  <particle> 1array append
-2 3 1 0  <particle> 1array append
-4 3 2 0  <particle> 1array append
10 -3 -1 1  <particle> 1array append
5 11 1 -2  <particle> 1array append
4 7 0 -1  <particle> 1array append
8 -2 0 1  <particle> 1array append
15 0 -2 0  <particle> 1array append
1 6 1 0  <particle> 1array append
8 9 0 -1  <particle> 1array append
3 3 -1 1  <particle> 1array append
0 5 0 -1  <particle> 1array append
-2 2 2 0  <particle> 1array append
5 -2 1 2  <particle> 1array append
1 4 2 1  <particle> 1array append
-2 7 2 -2  <particle> 1array append
3 6 -1 -1  <particle> 1array append
5 0 1 0  <particle> 1array append
-6 0 2 0  <particle> 1array append
5 9 1 -2  <particle> 1array append
14 7 -2 0  <particle> 1array append
-3 6 2 -1  <particle> 1array append

[ 5 over particles-in-vline? ]
[ dup [ move ] each ] do until

print-particles
