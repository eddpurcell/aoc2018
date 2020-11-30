USING: kernel namespaces vectors arrays byte-arrays sequences math math.parser io ;
USE: prettyprint

IN: hot-chocolate

SYMBOL: input
509671 input set
! 2018 input set
! 59414 input set

: input-as-string ( -- str ) input get number>string ;
: input-length ( -- n ) input-as-string length ;

: scores ( positions seq -- scores ) tuck [ dup second ] dip nth [ first swap nth ] dip 2array ;
: append-digits ( seq digits -- seq' ) [ over push ] each ;
: number>digits ( n -- digits ) number>string string>digits ;

: update-positions ( scores positions -- positions' ) [ + 1 + ] 2map ;
: adjust-positions ( n positions -- positions' ) [ over mod ] map nip ;

: nscores ( seq ind length -- answer ) dupd + rot subseq [ number>string ] map concat ;

: part-a-loop ( seq -- seq ? ) input get 10 + over length >= not ;
: part-a-answer ( seq -- ) input get 10 nscores write "\n" write ; 
: part-b? ( seq -- i/f ) dup length input-length - <iota> [ dupd input-length nscores input-as-string = ] find drop nip ;
: part-b-loop ( seq -- ? ) dup length input-length dup [ - ] dip nscores .s input-as-string = ;
: part-b-answer ( seq -- ) length input-length - . ;

{ 0 1 }
input get 8 * <vector>
3 over set-first
7 over set-second
1 over set-third
0 over set-fourth

[ part-a-loop ]
[
  2dup scores dup [ sum number>digits append-digits ] dip rot update-positions dupd [ length ] dip adjust-positions swap
] do until

dup part-a-answer

dup part-b? dup 
[ . drop ]
[
drop
  [ dup part-b-loop ]
  [
    2dup scores dup [ sum number>digits append-digits ] dip rot update-positions dupd [ length ] dip adjust-positions swap
  ] do until
  part-b-answer
] if
drop
