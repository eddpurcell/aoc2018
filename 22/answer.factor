USING: kernel accessors namespaces math memoize ;
USING: arrays sequences vectors sets hash-sets sorting ;
USE: prettyprint

FROM: namespaces => set ;

IN: cave-rescue

SYMBOL: depth

: target? ( xy -- ? ) [ first 13 = ] [ second 726 = ] bi and ;
: origin? ( xy -- ? ) [ first 0 = ] [ second 0 = ] bi and ;
: target-or-origin? ( xy -- ? ) [ origin? ] [ target? ] bi or ;

: left ( xy -- xy' ) [ first 1 - ] [ second ] bi 2array ;
: up ( xy -- xy' ) [ first ] [ second 1 - ] bi 2array ;

: 0y? ( xy -- ? ) first 0 = ;
: x0? ( xy -- ? ) second 0 = ;
: 0y-or-x0? ( xy -- ? ) [ 0y? ] [ x0? ] bi or ;

DEFER: erosion-level

MEMO: (geo-index-0y) ( xy -- n ) second 48271 * ;
MEMO: (geo-index-x0) ( xy -- n ) first 16807 * ;
MEMO: (geo-index-xy) ( xy -- n ) [ left erosion-level ] [ up erosion-level ] bi * ;
MEMO: geo-index ( xy -- n ) [ dup target-or-origin? [ 0 ] [ f ] if nip ]
                                  [ dup 0y? [ (geo-index-0y) ] [ dup x0? [ (geo-index-x0) ] [ drop f ] if ] if ]
                                  [ dup 0y-or-x0? not [ (geo-index-xy) ] [ drop f ] if ] tri
                                  3array sift first ;

MEMO: erosion-level ( xy -- n ) geo-index depth get + 20183 mod ;

MEMO: type ( xy -- n ) erosion-level 3 mod ;

: risk ( points -- n ) [ type ] map-sum ;

: interior-points ( target-xy -- points ) [ first 1 + <iota> ] [ second 1 + <iota> ] bi cartesian-product { } [ append ] reduce ;

! Example
! : target? ( xy -- ? ) [ first 10 = ] [ second 10 = ] bi and ;
! 510 depth set { 10 10 } interior-points

3066 depth set { 13 726 } interior-points

risk .

SYMBOL: +CLIMBING_GEAR+
SYMBOL: +TORCH+
SYMBOL: +NEITHER+

: h ( xy -- n ) [ first 13 - abs ] [ second 726 - abs ] bi + ;

TUPLE: move xy tool cost ;
: <move> ( xy tool cost -- move ) move boa ;
M: move equal? [ xy>> swap xy>> = ] [ tool>> swap tool>> = ] 2bi and ;

: down ( xy -- xy' ) [ first ] [ second 1 + ] bi 2array ;
: right ( xy -- xy' ) [ first 1 + ] [ second ] bi 2array ;
: neighbors ( xy -- xys ) dup [ up ] [ left ] bi [ [ down ] [ right ] bi ] 2dip 4array [ [ first 0 < ] [ second 0 < ] bi or ] reject ;

: g ( xytc -- n ) cost>> ;

: rocky-tool? ( tool -- ? ) { +CLIMBING_GEAR+ +TORCH+ } in? ;
: wet-tool? ( tool -- ? ) { +CLIMBING_GEAR+ +NEITHER+ } in? ;
: narrow-tool? ( tool -- ? ) { +TORCH+ +NEITHER+ } in? ;
: tool-appropriate? ( tool type -- ? ) dup 0 = [ drop rocky-tool? ] [ 1 = [ wet-tool? ] [ narrow-tool? ] if ] if ;

: other-tools ( tool -- tools ) { +CLIMBING_GEAR+ +TORCH+ +NEITHER+ } remove ;
: possible-moves ( xytc -- xytcs ) dup xy>> neighbors 
  [ [ over tool>> pick cost>> 1 + <move> ] map nip ]
  [ [ over tool>> other-tools [ pick cost>> 8 + [ dup ] 2dip <move> ] map nip ] map { } [ append ] reduce nip ] 2bi
  append
  [ [ tool>> ] [ xy>> type ] bi tool-appropriate? ] filter ;

: f ( xytc -- n ) dup xy>> h [ g ] dip + ;
: end? ( xytc -- ? ) dup xy>> target? [ tool>> +TORCH+ = ] dip and ;

: pull-first ( open -- first ) members [ f ] infimum-by ;
: unclip-first ( open -- open first ) dup pull-first over dupd delete ;

: a* ( start -- cost ) 1array >hash-set [ 200 <hash-set> ] dip ! ( closed-set open-set )
  [ dup cardinality 0 = over pull-first end? or ] 
  [ unclip-first pick dupd adjoin 
    possible-moves pick without over adjoin-all
  ] do until
  pull-first nip ;

! : h ( xy -- n ) [ first 10 - abs ] [ second 10 - abs ] bi + ;
{ 0 0 } +TORCH+ 0 <move>
a* .
