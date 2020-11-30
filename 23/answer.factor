USING: kernel math math.parser accessors ;
USING: sequences arrays vectors splitting sorting ;
USING: io io.files io.encodings.utf8 ;
USE: prettyprint

IN: nanobot-teleportation

TUPLE: nanobot { x integer read-only } { y integer read-only } { z integer read-only } { radius integer read-only } ;
: <nanobot> ( x y z radius -- nanobot ) nanobot boa ;

: manhattan-distance ( nano1 nano2 -- n ) [ x>> swap x>> - abs ] [ y>> swap y>> - abs ] [ z>> swap z>> - abs ] 2tri + + ;

: get-neighbors ( nano nanos -- neighbors ) [ over manhattan-distance over radius>> <= ] filter nip ;

1000 <vector>
"/Users/edd.purcell/projects/aoc2018/23/input-clean.txt" utf8 [
  [
    " " split [ string>number ] map dup [ first ] dip [ second ] [ third ] [ fourth ] tri <nanobot> over push
  ] each-line
] with-file-reader

[ [ radius>> ] supremum-by ] keep tuck get-neighbors length .

TUPLE: position { x integer read-only } { y integer read-only } { z integer read-only } { bots integer initial: 0 } ;
: <position> ( x y z -- position ) 0 position boa ;
M: position equal? [ x>> swap x>> = ] [ y>> swap y>> = ] [ z>> swap z>> = ] 2tri and and ;

: hits-position ( position nanos -- nanos' ) [ [ over manhattan-distance ] keep radius>> <= ] filter nip ;
: candidate-position ( bots -- candidate ) dup [ [ x>> ] [ y>> ] [ z>> ] tri <position> over dupd hits-position length >>bots ] map [ bots>> ] supremum-by nip ;

: neighbor-cube ( -- points ) 3 <iota> [ 1 - ] map dup dup cartesian-product { } [ append ] reduce
                              cartesian-product { } [ [ [ first ] [ second [ first ] [ second ] bi ] bi 3array ] map append ] reduce ;
: neighbor-positions ( position -- positions ) neighbor-cube [ over [ x>> swap first + ] [ y>> swap second + ] [ z>> swap third + ] 2tri <position> ] map nip ;
dup candidate-position 

[ [ neighbor-positions [ over dupd hits-position length >>bots ] map [ bots>> ] supremum-by ] keep over = not ] loop . drop
