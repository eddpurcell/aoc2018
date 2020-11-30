USING: namespaces kernel prettyprint accessors arrays sequences io.files io.encodings.utf8 regexp math.parser math ;

IN: fabric-claims
SYMBOL: memo
1000000 0 <array> memo set

TUPLE: claim id x y w h ;
: <claim> ( -- claim ) claim new ;

TUPLE: point x y ;
: <point> ( -- point ) point new ;

: point>ind ( point -- n ) dup y>> 1000 * swap x>> + ;
: claimed? ( point -- ? ) point>ind memo get nth 0 = not ;
: mark-owned ( id point -- ) point>ind memo get set-nth ;
: mark-contentious ( point -- ) -1 swap mark-owned ;

: get-all-xs ( claim -- seq ) dup w>> <iota> [ over x>> + ] map nip ;
: get-all-ys ( claim -- seq ) dup h>> <iota> [ over y>> + ] map nip ;
: flatten ( seq -- seq' ) { } [ append ] accumulate drop ;
: get-claimed-indices ( claim -- points ) dup get-all-xs swap get-all-ys cartesian-product flatten
  [ <point> over first >>x over second >>y nip ] map ;
: lay-claim ( claim -- ) get-claimed-indices [ dup claimed? [ mark-contentious ] [ 1 swap mark-owned ] if ] each ;

SYMBOL: claims

"input.txt" utf8 file-lines 
[ <claim> over R/ #\d+/ first-match CHAR: # swap remove string>number >>id
          over R/ \d+,/ first-match CHAR: , swap remove string>number >>x
          over R/ ,\d+/ first-match CHAR: , swap remove string>number >>y
          over R/ \d+x/ first-match CHAR: x swap remove string>number >>w
          over R/ x\d+/ first-match CHAR: x swap remove string>number >>h
          nip ] map claims set

claims get [ lay-claim ] each

memo get [ -1 = ] filter length .

: contentious-claim? ( claim -- ? ) get-claimed-indices [ point>ind memo get nth ] map [ -1 = ] filter length 0 > ; 

claims get [ contentious-claim? not ] filter first id>> .
