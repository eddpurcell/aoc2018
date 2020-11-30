USING: accessors arrays kernel math math.parser math.ranges sequences sets splitting vectors io.files io.encodings.utf8 ;
USING: prettyprint ;

IN: nng
TUPLE: point x y neighbors ;
: <point> ( -- point ) point new ;
: point>xy ( point -- {xy} ) dup x>> swap y>> 2array ;

: minmax ( seq -- min max ) dup infimum swap supremum ;
: xs ( seq -- seq' ) [ x>> ] map ;
: ys ( seq -- seq' ) [ y>> ] map ;
: <xrange> ( seq -- range ) xs minmax 1 <range> ; 
: <yrange> ( seq -- range ) ys minmax 1 <range> ;
: flatten ( seq -- seq' ) { } [ append ] accumulate drop ;
: collect-points ( xs ys -- seq' ) cartesian-product flatten ;
: without-points ( xys points -- xys' ) [ dup x>> swap y>> 2array ] map without ;

: infimums-by ( points quote -- points' ) 3dup map infimum nip [ 3dup map nip ] dip swap indices nip swap nths ; inline

: manhattan ( point point -- n ) 2dup first swap first - abs [ last swap last - abs ] dip + ;
: on-xedge? ( x point -- ? ) neighbors>> [ first ] map [ over = ] any? nip ;
: on-yedge? ( y point -- ? ) neighbors>> [ second ] map [ over = ] any? nip ;
: on-xyedge? ( point corner -- ? ) 2dup first swap on-xedge? [ 2drop t ] [ second swap on-yedge? ] if ;
: infinite? ( point corners -- ? ) 2dup first on-xyedge? [ 2drop t ] [ second on-xyedge? ] if ;

"input.txt" utf8 file-lines 
[ "," split1 <point> swap string>number >>y swap string>number >>x 10 <vector> >>neighbors ] map ! ( points )
dup <xrange> over <yrange> collect-points ! ( points xy-coords )

[ ! ( points | xy-coord )
  over [ ! ( points xy-coord | point )
    point>xy over manhattan ! ( points xy-coord | n )
  ] infimums-by ! ( points | xy-coord nns ) 
  dup length 1 >
  [ 2drop ]
  [ first neighbors>> push ]
  if
] each

dup xs minmax 2array over ys minmax 2array [ 2array ] 2map ! ( points corners )
swap [ ! ( corners | point )
  over infinite?
] reject nip ! ( finite-points )
[ neighbors>> length ] map supremum .

: center-region? ( coord points -- ? ) [ point>xy over manhattan ] map-sum nip 10000 < ;

"input.txt" utf8 file-lines 
[ "," split1 <point> swap string>number >>y swap string>number >>x 10 <vector> >>neighbors ] map ! ( points ) 
dup <xrange> over <yrange> collect-points ! ( points xy-coords )

[
  over center-region? not
] reject length .
