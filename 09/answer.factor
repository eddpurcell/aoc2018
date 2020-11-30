USING: accessors kernel shuffle namespaces math sequences prettyprint ;

IN: marbles

SYMBOL: points
V{ } clone points set
: add-score ( n -- ) points get push ;

TUPLE: marble value next prev ;
: <marble> ( value -- marble ) [ marble new ] dip >>value dup >>next dup >>prev ;

: place-marble2 ( curr-marble n -- curr-marble' ) 
  [ next>> ] dip
  <marble>
  over >>prev 
  over next>> >>next
  tuck swap next<< dup next>> over >>prev drop ; 

: remove-marble2 ( curr-marble -- curr-marble' )
  7 <iota> [ drop prev>> ] each
  dup prev>> over next>> prev<<
  dup next>> over prev>> next<<
  dup value>> add-score
  next>> ;

SYMBOL: max-value
7201900 max-value set
SYMBOL: nplayers
458 nplayers set

: place-marble ( n curr-ind marbles -- curr-ind marbles ) swap 2 + over length mod dup [ swap insert-nth ] dip swap ;
: ind-to-remove ( curr-ind marbles -- ind ) swap 7 - dup 0 < [ swap length + ] [ nip ] if ;
: remove-marble ( curr-ind marbles -- curr-ind marbles ) swap over ind-to-remove swap 2dup nth add-score over [ remove-nth ] dip swap ;

0 <marble> ! ( marbles )
max-value get
<iota> [ 1 + ] map
[
  dup 23 mod 0 =
  [ drop remove-marble2 ]
  [ place-marble2 ]
  if
] each

drop
 
: nth-or-0 ( ind seq -- 0/n ) 2dup length < [ nth ] [ 2drop 0 ] if ;
: set-nth+ ( n ind seq -- seq ) dup [ rot [ 2dup nth-or-0 ] dip + -rot set-nth ] dip ;
: players>score-inds ( nplayers max-value -- seq ) <iota> [ 1 + ] map [ 23 mod 0 = ] filter [ over mod ] map nip ;
: add-23s ( -- ) points get [ 1 + 23 * + ] map-index points set ;
: scores ( nplayers max-value -- seq ) [ points get ] 2dip players>score-inds V{ } [ rot set-nth+ ] 2reduce ;

add-23s
nplayers get max-value get scores supremum .
