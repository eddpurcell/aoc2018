USING: kernel math namespaces accessors prettyprint io.files io.encodings.utf8 regexp sequences ;

IN: polymers

: find-root ( str -- f/slice ) R/ aA|Aa|bB|Bb|cC|Cc|dD|Dd|eE|Ee|fF|Ff|gG|Gg|hH|Hh|iI|Ii|jJ|Jj|kK|Kk|lL|Ll|mM|Mm|nN|Nn|oO|Oo|pP|Pp|qQ|Qq|rR|Rr|sS|Ss|tT|Tt|uU|Uu|vV|Vv|wW|Ww|xX|Xx|yY|Yy|zZ|Zz/ first-match ;

: seq>slicepairs ( seq -- seq ) dup length 1 - <iota> [ dup 2 + pick <slice> ] map nip ;
: slice>subseq ( slice -- seq ) dup from>> swap dup to>> swap seq>> subseq ;

: grow-slice? ( slice -- ? ) dup from>> 0 = swap dup to>> swap seq>> length >= or not ;
: grow-slice ( slice -- slice/slice' ) dup grow-slice? [ dup from>> 1 - over to>> 1 + rot seq>> <slice> ] [ ] if ;
: annihilate? ( slice -- ? ) slice>subseq dup first swap last 0x20 bitxor = ;

: slices-mix? ( slice slice+1 -- ? ) from>> swap to>> < ;
: clean-out ( seq -- seq ) dup 
[
  1 + pick 2dup bounds-check?
  [ nth 2dup slices-mix?
    [ 2drop f ] [ drop ] if
  ] 
  [ 2drop ]
  if 
] map-index harvest nip ;

SYMBOL: annihilations
V{ } annihilations set

"input.txt" utf8 file-contents
! "dabAcCaCBAcCcaDA"
dup length 1 - swap 
! seq>slicepairs
! [ dup annihilate? 
!   [ 
!     [ dup grow-slice? over grow-slice annihilate? and ] 
!     [ grow-slice ] 
!     while 
!   ] 
!   [ drop f ] 
!   if 
! ] map harvest clean-out

[ dup find-root ]
[
  dup find-root
  [ dup grow-slice? over grow-slice annihilate? and ] 
  [ grow-slice ] while
  nip "" over dup from>> swap dup to>> swap seq>> replace-slice swap
  annihilations get push
] do while
drop
annihilations get [ length ] map-sum - .


: lower ( str -- str' ) [ 0x20 bitor ] map ;

"input.txt" utf8 file-contents
USING: sets ;
dup lower members [
  USING: namespaces vectors ;
  annihilations get delete-all
  over [ 0x20 bitor over = ] reject
  dup length 1 - swap
  [ dup find-root ]
  [
    dup find-root
    [ dup grow-slice? over grow-slice annihilate? and ] 
    [ grow-slice ] while
    nip "" over dup from>> swap dup to>> swap seq>> replace-slice swap
    annihilations get push
  ] do while
  drop nip
  annihilations get [ length ] map-sum -
] map infimum .
