USING: memoize kernel sets sequences arrays strings math math.parser prettyprint vectors math.order ;
USE: io

IN: fuel-cells

: flatten ( seq -- seq' ) { } [ append ] reduce ;
: >points ( xs ys -- seq ) cartesian-product flatten ;
: >squares ( xs ys size -- seq ) [ >points ] dip 1array [ 1array append ] cartesian-map flatten ;

: x ( point -- x ) first ;
: y ( point -- y ) second ;
: size ( point -- size ) third ;
: point>xy ( point -- x y ) dup x swap y ;
: xy>point ( x y -- point ) 2array ;

: rack-id ( x -- n ) 10 + ;
: base-power-level ( y x -- n ) rack-id * ;
: add-serial-number ( n -- n' ) 8141 + ;
! : add-serial-number ( n -- n' ) 42 + ;
: get-hundreths-place ( n -- n' ) number>string reverse third 1string string>number ;
: calculate-cell-power ( x y -- n ) over base-power-level add-serial-number swap rack-id * get-hundreths-place 5 - ;

: point-to-grid ( point -- points ) dup size <iota> dup [ [ over x + ] map ] dip rot swap [ over y + ] map nip >points ;
: rim-points ( point n -- points ) dup <iota> [ pick x pick 1 - + [ pick y + ] dip swap 2array ] map
                                      [ dup <iota> [ pick y pick 1 - + [ pick x + ] dip 2array ] map ] dip union 2nip ;

: sum-points ( point -- points ) 2 <vector>
  over point>xy swap 1 - dup 0 > [ swap 2array over push ] [ 2drop ] if
  over point>xy 1 - dup 0 > [ 2array over push ] [ 2drop ] if nip ;

: diff-point ( point -- points ) 1 <vector>
  over point>xy 1 - dup 0 > [ swap 1 - dup 0 > ] dip and [ swap 2array over push ] [ 2drop ] if nip ;

: 0point? ( point -- ? ) dup x 0 = swap y 0 = or ;

MEMO: calculate-sum-table ( point -- n ) dup 0point? 
  [ drop 0 ]
  [ dup point>xy calculate-cell-power [ dup sum-points [ calculate-sum-table ] map-sum ] dip + swap diff-point [ calculate-sum-table ] map-sum - ] if ;

MEMO: calculate-group-power ( point n -- n ) dup 1 = 
  [ drop dup x swap y calculate-cell-power ]
  [ 2dup 1 - calculate-group-power [ rim-points [ dup x swap y calculate-cell-power ] map-sum ] dip + ] if ;

: point-1 ( point -- point' ) point>xy [ 1 - ] dip 1 - xy>point ;

: point>corners ( n point -- points ) point-1 4 swap <array> swap
  over first point>xy swap pick + swap xy>point pick set-second
  over first point>xy pick + xy>point pick set-third
  over first point>xy pick + swap pick + swap xy>point pick set-fourth drop ;

: power-level ( n point -- n ) point>corners
  dup fourth calculate-sum-table
  over third calculate-sum-table -
  over second calculate-sum-table -
  swap first calculate-sum-table + ;

! 298 <iota> [ 1 + ] map dup >points [ 3 <iota> [ 1 + over swap calculate-group-power ] supremum-by nip ] map .

298 <iota> [ 1 + ] map dup >points [ 3 swap power-level ] supremum-by .

300 <iota> [ 1 + ] map dup >points [ 301 over point>xy min - <iota> [ 1 + ] map [ over power-level ] supremum-by 2array ] map [ dup second swap first power-level ] supremum-by .
