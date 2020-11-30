USING: kernel sequences arrays sets accessors classes math ;
USING: io io.files io.encodings.utf8 ;
USE: prettyprint

FROM: namespaces => get set ;

IN: north-pole-lumber

SYMBOL: size
50 size set

SYMBOL: seen
V{ } clone seen set

TUPLE: lumberyard x y ;
: <lumberyard> ( x y -- lumberyard ) lumberyard boa ;
TUPLE: open-acre x y ;
: <open-acre> ( x y -- open-acre ) open-acre boa ;
TUPLE: trees x y ;
: <trees> ( x y -- trees ) trees boa ;

: obj>xy ( obj -- x y ) [ x>> ] [ y>> ] bi ;

TUPLE: intermediary obj neighbors ;

GENERIC: change ( neighbors obj -- obj' )

M: lumberyard change ( neighbors obj -- obj' ) swap [ [ lumberyard instance? ] filter length 1 >= ] [ [ trees instance? ] filter length 1 >= ] bi and [ ] [ obj>xy <open-acre> ] if ;
M: open-acre change ( neighbors obj -- obj' ) swap [ trees instance? ] filter length 3 >= [ obj>xy <trees> ] [ ] if ;
M: trees change ( neighbors obj -- obj' ) swap [ lumberyard instance? ] filter length 3 >= [ obj>xy <lumberyard> ] [ ] if ;

: (is-valid?) ( n -- t/f ) [ 0 >= ] [ size get < ] bi and ;
: is-valid? ( x y -- t/f ) [ (is-valid?) ] dip (is-valid?) and ;
: (x-neighbors) ( x y -- xys ) [ [ 1 - ] [ ] [ 1 + ] tri ] dip tuck 2array [ tuck 2array ] dip [ 2array ] 2dip 3array ;
: expand-xy ( xy -- x y ) [ first ] [ second ] bi ;
: neighbors ( x y -- xys ) [ 1 - (x-neighbors) ] [ 2dup 2array [ (x-neighbors) ] dip swap remove ] [ 1 + (x-neighbors) ] 2tri append append [ expand-xy is-valid? ] filter ;
: obj-at ( xy objs -- obj ) [ expand-xy size get * + ] dip nth ;

: is-tree? ( str -- ? ) CHAR: | = ;
: is-lumberyard? ( str -- ? ) CHAR: # = ;
: is-open? ( str -- ? ) CHAR: . = ;
: ind>xy ( ind -- x y ) [ size get mod ] [ size get /i ] bi ;
: char>obj ( ind str -- obj ) [ is-tree? [ ind>xy <trees> ] [ drop f ] if ] [ is-lumberyard? [ ind>xy <lumberyard> ] [ drop f ] if ] [ is-open? [ ind>xy <open-acre> ] [ drop f ] if ] 2tri 3array sift first ;
: parse-line ( objs ind str -- objs' ind' ) [ dupd char>obj pick pick swap set-nth 1 + ] each ;

size get dup * null <array> 0
"/Users/edd.purcell/projects/aoc2018/18/input.txt" utf8 file-lines
[
  parse-line
] each

: obj>str ( obj -- str ) [ trees instance? [ "|" ] [ f ] if ] [ lumberyard instance? [ "#" ] [ f ] if ] [ open-acre instance? [ "." ] [ f ] if ] tri 3array sift first ;
: print-chart ( objs -- ) [ size get mod 0 = [ "\n" write ] [ ] if obj>str write ] each-index "\n" write ;
: parse-state ( str -- objs ) [ swap char>obj ] map-index ;

: resource-value ( objs -- n ) [ [ trees instance? ] filter length ] [ [ lumberyard instance? ] filter length ] bi * ;

: tick ( objs -- objs objs' ) 
  dup
  [
    dup obj>xy neighbors [ pick obj-at ] map intermediary boa
  ] map
  [
    [ neighbors>> ] [ obj>> ] bi change
  ] map ;


: chart>str ( objs -- str ) [ obj>str ] map concat ;

drop
! 10 <iota> [
!   drop
!   tick
!   nip
! !   dup print-chart
! !   "\n" write
! ] each
! dup resource-value .

! dup print-chart

dup
[ dup [ obj>str ] map concat seen get ?adjoin ]
[
  nip tick
] do while
nip dup print-chart
1000000000 seen get [ pick chart>str = ] find drop dup dup [ - seen get length ] 2dip [ -  mod ] dip + 1 - seen get nth parse-state
resource-value .
drop
