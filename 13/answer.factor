USING: kernel namespaces io.files io.encodings.utf8 regexp sequences math math.order classes.tuple.private slots.private ;
USING: accessors prettyprint sorting arrays memoize sets ;
USE: io
FROM: namespaces => set ;

IN: track-crashes

SYMBOL: +N+ inline
0 +N+ set
SYMBOL: +SOUTH+ inline
2 +SOUTH+ set
SYMBOL: +E+ inline
3 +E+ set
SYMBOL: +W+ inline
1 +W+ set

SYMBOL: +TR+ inline
SYMBOL: +TL+ inline
SYMBOL: +BR+ inline
SYMBOL: +BL+ inline

SYMBOL: +L+ inline
SYMBOL: +S+ inline
SYMBOL: +R+ inline

TUPLE: corner { x integer read-only } { y integer read-only } { point read-only } ;
: <corner> ( x y point -- corner ) corner boa ;
: tcorner? ( object -- ? ) dup tuple? [ layout-of 7 slot \ corner eq? ] [ drop f ] if ;

TUPLE: intersection { x integer read-only } { y integer read-only } ;
: <intersection> ( x y -- intersection ) intersection boa ;
: tintersection? ( object -- ? ) dup tuple? [ layout-of 7 slot \ intersection eq? ] [ drop f ] if ;

TUPLE: cart { x integer } { y integer } dir { next-turn initial: +L+ } { crashed initial: f } ;
: <cart> ( x y dir -- cart ) +L+ f cart boa ;

: turn-corner ( corner cart -- ) over point>> +TL+ eq? 
  [ dup dir>> +W+ eq?
    [ +SOUTH+ >>dir ]
    [ +E+ >>dir ] if
  ]
  [ over point>> +TR+ eq? 
    [ dup dir>> +E+ eq?
      [ +SOUTH+ >>dir ]
      [ +W+ >>dir ] if
    ]
    [
      over point>> +BL+ eq?
      [ dup dir>> +W+ eq?
        [ +N+ >>dir ]
        [ +E+ >>dir ] if
      ]
      [ dup dir>> +E+ eq?
        [ +N+ >>dir ]
        [ +W+ >>dir ] if
      ] if
    ] if
  ] if 2drop ;
: n>dir ( n -- dir ) dup 0 =
  [ drop +N+ ]
  [
    dup 1 =
    [ drop +W+ ]
    [
      dup 2 =
      [ drop +SOUTH+ ]
      [ drop +E+ ] if
    ] if
  ] if ;
: turn-left ( dir -- dir' ) get 1 + 4 mod n>dir ;
: turn-right ( dir -- dir' ) get 1 - 4 + 4 mod n>dir ;

: turn-intersection ( cart -- ) dup next-turn>> +R+ eq?
  [ dup dir>> turn-right >>dir +L+ >>next-turn ]
  [ 
    dup next-turn>> +L+ eq?
    [ dup dir>> turn-left >>dir +S+ >>next-turn ]
    [ +R+ >>next-turn ] if
  ] if drop ;
: turn ( turn cart -- ) over tcorner? [ turn-corner ] [ nip turn-intersection ] if ;

: obj>xy ( obj -- xy ) dup x>> swap y>> 2array ;

MEMO: turn? ( xy turns -- ? ) [ obj>xy over = ] find 2nip ;

: get-indices ( string regexp -- indices ) all-matching-slices [ from>> ] map ;

: get-tl-corners ( string -- indices ) R/ \/[-+<^>v]/ get-indices ;
: get-bl-corners ( string -- indices ) R/ \\[-+<^>v]/ get-indices ;
: get-tr-corners ( string -- indices ) R/ [-+<^>v]\Q\\E/ get-indices [ 1 + ] map ;
: get-br-corners ( string -- indices ) R/ [-+<^>v]\// get-indices [ 1 + ] map ;
: get-corners ( string y -- string y corners ) 
  over get-tl-corners [ over +TL+ <corner> ] map
  [ over get-bl-corners [ over +BL+ <corner> ] map ] dip append
  [ over get-tr-corners [ over +TR+ <corner> ] map ] dip append
  [ over get-br-corners [ over +BR+ <corner> ] map ] dip append ;

: get-intersections ( string y -- intersections ) swap R/ \+/ get-indices [ over <intersection> ] map nip ;

: get-turns ( string y -- turns ) get-corners [ get-intersections ] dip append ;

: get-down-carts ( string -- incides ) R/ v/ get-indices ;
: get-up-carts ( string -- indices ) R/ \^/ get-indices ;
: get-left-carts ( string -- indices ) R/ </ get-indices ;
: get-right-carts ( string -- indices ) R/ >/ get-indices ;
: get-carts ( string y -- carts )
  over get-down-carts [ over +SOUTH+ <cart> ] map
  [ over get-up-carts [ over +N+ <cart> ] map ] dip append
  [ over get-left-carts [ over +W+ <cart> ] map ] dip append
  [ over get-right-carts [ over +E+ <cart> ] map ] dip append
  2nip ;

: read-initial-state ( turns carts filepath -- turns carts ) utf8 file-lines [
!    over write "\n" write
    2dup [ get-carts append ] 2dip get-turns rot append swap
  ] each-index ;

: crashed-carts? ( carts -- ? ) [ crashed>> ] any? ;
: carts-at ( xy carts -- carts' ) [ dup crashed>> not [ obj>xy over  = ] dip and ] filter nip ;

: sort-carts ( carts -- carts' ) [ over y>> over y>> = not [ y>> swap y>> swap <=> ] [ [ x>> ] dip x>> <=> ] if ] sort ;

: move ( cart -- cart' ) dup dir>> get dup 2 mod 0 = [ 1 - over y>> + >>y ] [ 2 - over x>> + >>x ] if ;

: move-carts ( carts -- carts' ) sort-carts dup [ dup crashed>> [ ] [ move dup obj>xy pick carts-at dup length 1 > [ dup first obj>xy . [ t >>crashed drop ] each ] [ drop ] if ] if ] map nip ;
: turn-carts ( turns carts -- turns carts' ) [ dup crashed>> [ ] [ dup obj>xy pick turn? dup [ over turn ] [ drop ] if ] if ] map ;

: tick ( turns carts -- turns carts' ) move-carts turn-carts ; inline

{ } clone { } clone "/Users/edd.purcell/projects/aoc2018/13/input.txt" read-initial-state
 [ dup [ crashed>> ] reject length 1 = ]
 [ tick ] do until
"last cart: " write
nip [ crashed>> not ] find obj>xy . drop
