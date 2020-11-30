USING: kernel memoize regexp math math.parser continuations ;
USING: sequences sets vectors arrays splitting ;
USING: io io.files io.encodings.utf8 ;
USE: prettyprint

FROM: namespaces => set get ;
IN: water-flows

SYMBOL: ground-map

: add-vline ( clays x ys -- clays ) [ dupd 2array pick push ] each drop ;
: add-hline ( clays y xs -- clays ) [ over 2array pick push ] each drop ;
: parse-first-number ( str -- n ) R/ \d+/ first-match string>number ;
: parse-range ( str -- ns ) R/ \d+\.\.\d+/ first-match "." split dup first string>number swap third string>number 1 + over - <iota> [ over + ] map nip ;
: parse-line ( clays string -- clays ) dup first CHAR: x = [ "," split dup first parse-first-number swap second parse-range ] dip [ add-vline ] [ add-hline ] if ;

! MEMO: clay? ( xy -- ? ) clays get in? ;
! : water? ( xy -- ? ) waters get in? ;

: <range> ( min max -- min..max ) over 1 - - <iota> [ over + ] map nip ;
: minmax ( ns -- min max ) dup infimum swap supremum ;
: flatten ( seq -- seq' ) { } [ append ] reduce ;
: print-map ( -- ) ground-map get [ concat write "\n" write ] each ;

"/Users/edd.purcell/projects/aoc2018/17/input.txt" utf8 [
  500 <vector>
  [ parse-line ] each-line
  dup [ second ] map infimum swap [ [ first ] [ second pick - ] bi 2array ] map nip
  dup [ first ] map infimum dup [ swap [ [ first over - ] [ second ] bi 2array ] map nip ] dip 
  501 swap - swap ! 1+ for the padding
] with-file-reader

dup [ [ second ] map supremum 1 + ] ! 1+ for 0 start
    [ [ first ] map supremum 3 + "." <repetition> >array ] bi ! 2+ to allow for overflow off the edges, 1+ for 0 start
<array> [ clone ] map ground-map set

[ 
  [ first 1 + "#" swap ]
  [ second ground-map get nth ] bi
  set-nth
] each

: @y ( y -- str ) ground-map get nth ;
: @xy ( xy -- str ) dup second @y [ first ] dip nth ;
: !xy ( str xy -- ) dup second @y [ first ] dip set-nth ;
: clay? ( xy -- ? ) @xy "#" = ;
: water-settled? ( xy -- ? ) @xy "~" = ;
: water-flow? ( xy -- ? ) @xy "|" = ;
: water? ( xy -- ? ) [ water-settled? ] [ water-flow? ] bi or ;
: solid? ( xy -- ? ) [ clay? ] [ water-settled? ] bi or ;
: stop-drop? ( xy -- ? ) [ clay? ] [ water? ] bi or ;
: !water-flow ( xy -- ) "|" swap !xy ;
: !water-settled ( xy -- ) "~" swap !xy ;

: down1 ( xy -- xy+1 ) [ first ] [ second 1 + ] bi 2array ;
: up1 ( xy -- xy-1 ) [ first ] [ second 1 - ] bi 2array ;
: left1 ( xy -- x-1y ) [ first 1 - ] [ second ] bi 2array ;
: right1 ( xy -- x+1y ) [ first 1 + ] [ second ] bi 2array ;

: drop-head ( xy -- xy'/f ) [ [ dup stop-drop? ] [ dup !water-flow down1 ] do until dup water-flow? [ drop f ] [ up1 ] if ] [ 2drop f ] recover ;
: spread-left ( xy -- ) [ dup solid? ] [ dup !water-settled left1 ] do until drop ;
: spread-right ( xy -- ) [ dup solid? ] [ dup !water-settled right1 ] do until drop ;
: spread-water ( xy -- xy-1 ) dup spread-left dup spread-right up1 ;

: contained-left? ( xy -- ? ) dup [ first ] [ second @y ] bi [ "#" = ] find-last-from drop dup
                              [ swap down1 [ first ] [ second @y ] bi
                                [ over - 1 + <iota> [ over + ] map nip ] dip
                                swap [ over nth [ "#" = ] [ "~" = ] bi or ] all? nip
                              ] [ nip ] if ;
: contained-right? ( xy -- ? ) dup [ first ] [ second @y ] bi [ "#" = ] find-from drop dup
                              [ swap down1 [ first ] [ second @y ] bi
                                [ swap over - 1 + <iota> [ over + ] map nip ] dip
                                swap [ over nth [ "#" = ] [ "~" = ] bi or ] all? nip
                              ] [ nip ] if ;
: contained? ( xy -- ? ) [ contained-left? ] [ contained-right? ] bi and ;

: fill-basin ( xy -- xy-1 ) [ dup contained? ] [ spread-water ] while ;

: flow-left ( xy -- xy/f ) left1 [ dup [ down1 solid? ] [ solid? not ] bi and ] [ dup !water-flow left1 ] while dup down1 solid? [ drop f ] [ dup !water-flow ] if ;
: flow-right ( xy -- xy/f ) right1 [ dup [ down1 solid? ] [ solid? not ] bi and ] [ dup !water-flow right1 ] while dup down1 solid? [ drop f ] [ dup !water-flow ] if ;
: overflow ( xy -- xys ) [ flow-left ] [ flow-right ] bi 2array harvest ;

: #waters ( -- n ) ground-map get length <iota> [ @y [ [ "~" = ] filter length ] [ [ "|" = ] filter length ] bi + ] map-sum ;
: #retained-waters ( -- n ) ground-map get length <iota> [ @y [ "~" = ] filter length ] map-sum ;

0 2array 1vector ! ( water-heads )
[ dup length 0 > ]
[
  [
"H" . .s
    drop-head dup [ fill-basin overflow  ] [ drop { } ] if
  ] map flatten
] do while 
drop
print-map
#waters .
#retained-waters .
