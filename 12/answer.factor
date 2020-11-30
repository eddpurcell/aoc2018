USING: kernel namespaces accessors sequences strings math arrays vectors sets memoize ;
USE: prettyprint

IN: pot-lyfe

TUPLE: rule { pattern slice read-only } { result string read-only } ;
: <rule> ( slice result -- rule ) rule boa ;
: rule-match? ( slice rule -- ? ) pattern>> = ;
: match-rules ( slice rules -- rule ) [ over swap rule-match? ] filter first nip ;
: apply-rule ( string rule -- string' ) result>> append ;

TUPLE: state { line string } { 0ind integer initial: 0 } ;
: <state> ( line 0ind -- state ) state boa ;
: sum-state ( state -- n ) dup 0ind>> swap line>> [ swap CHAR: . = [ drop 0 ] [ over + ] if ] map-index sum nip ;

: trim-line ( string -- string' n ) dup [ CHAR: # = ] find drop dup 2 +
                                     [ over [ CHAR: # = ] find-last drop 1 +
                                       rot subseq ] dip ;
: pad-line ( string n -- string' n ) [ "..." swap append "..." append ] dip 3 - ;
: prep-line ( string -- string' n ) trim-line pad-line ;
: setup-next ( state string -- state' ) prep-line pick 0ind>> + pick 0ind<< >>line ;

: pad-over ( string -- string' n ) ".................................................." swap append 
  ".................................................." append 50 ;

SYMBOL: prev-states
200 <vector> prev-states set

: string>slices ( string -- slices ) dup length 4 - <iota> [ dup 5 + pick <slice> ] map nip ;

: step ( rules slices -- rules string ) "" [ pick match-rules apply-rule ] reduce ;

{ }
! 0 5 "....." <slice> "." <rule> 1array append
! 0 5 "#...." <slice> "." <rule> 1array append
! 0 5 ".#..." <slice> "#" <rule> 1array append
! 0 5 "..#.." <slice> "#" <rule> 1array append
! 0 5 "...#." <slice> "." <rule> 1array append
! 0 5 "....#" <slice> "." <rule> 1array append
! 0 5 "##..." <slice> "." <rule> 1array append
! 0 5 ".##.." <slice> "#" <rule> 1array append
! 0 5 "..##." <slice> "." <rule> 1array append
! 0 5 "...##" <slice> "#" <rule> 1array append
! 0 5 "#.#.." <slice> "." <rule> 1array append
! 0 5 ".#.#." <slice> "#" <rule> 1array append
! 0 5 "..#.#" <slice> "." <rule> 1array append
! 0 5 "#..#." <slice> "." <rule> 1array append
! 0 5 ".#..#" <slice> "." <rule> 1array append
! 0 5 "#...#" <slice> "." <rule> 1array append
! 0 5 "###.." <slice> "#" <rule> 1array append
! 0 5 ".###." <slice> "." <rule> 1array append
! 0 5 "..###" <slice> "." <rule> 1array append
! 0 5 "##.#." <slice> "#" <rule> 1array append
! 0 5 ".##.#" <slice> "." <rule> 1array append
! 0 5 "#.##." <slice> "." <rule> 1array append
! 0 5 ".#.##" <slice> "#" <rule> 1array append
! 0 5 "#..##" <slice> "." <rule> 1array append
! 0 5 "##..#" <slice> "." <rule> 1array append
! 0 5 "#.#.#" <slice> "#" <rule> 1array append
! 0 5 ".####" <slice> "#" <rule> 1array append
! 0 5 "#.###" <slice> "#" <rule> 1array append
! 0 5 "##.##" <slice> "#" <rule> 1array append
! 0 5 "###.#" <slice> "#" <rule> 1array append
! 0 5 "####." <slice> "#" <rule> 1array append
! 0 5 "#####" <slice> "." <rule> 1array append
! state new
! "#..#.#..##......###...###"

0 5 "#..#." <slice> "#" <rule> 1array append
0 5 ".###." <slice> "." <rule> 1array append
0 5 "..##." <slice> "." <rule> 1array append
0 5 "....#" <slice> "." <rule> 1array append
0 5 "#...#" <slice> "." <rule> 1array append
0 5 ".#.#." <slice> "." <rule> 1array append
0 5 "#.#.#" <slice> "#" <rule> 1array append
0 5 "#...." <slice> "." <rule> 1array append
0 5 "#.#.." <slice> "#" <rule> 1array append
0 5 "###.#" <slice> "." <rule> 1array append
0 5 ".#..." <slice> "#" <rule> 1array append
0 5 "#.###" <slice> "." <rule> 1array append
0 5 ".#.##" <slice> "#" <rule> 1array append
0 5 "..#.." <slice> "#" <rule> 1array append
0 5 ".####" <slice> "." <rule> 1array append
0 5 "..###" <slice> "#" <rule> 1array append
0 5 "...#." <slice> "." <rule> 1array append
0 5 "##.#." <slice> "#" <rule> 1array append
0 5 "##.##" <slice> "#" <rule> 1array append
0 5 ".##.#" <slice> "#" <rule> 1array append
0 5 "###.." <slice> "." <rule> 1array append
0 5 "..#.#" <slice> "." <rule> 1array append
0 5 "...##" <slice> "#" <rule> 1array append
0 5 "##..." <slice> "#" <rule> 1array append
0 5 "#####" <slice> "." <rule> 1array append
0 5 "#.##." <slice> "." <rule> 1array append
0 5 ".#..#" <slice> "#" <rule> 1array append
0 5 "##..#" <slice> "." <rule> 1array append
0 5 "....." <slice> "." <rule> 1array append
0 5 "####." <slice> "#" <rule> 1array append
0 5 "#..##" <slice> "." <rule> 1array append
0 5 ".##.." <slice> "#" <rule> 1array append
state new
"##.#.####..#####..#.....##....#.#######..#.#...........#......##...##.#...####..##.#..##.....#..####"

setup-next -3 >>0ind

! 20 <iota> [ drop dup
!   [ line>> string>slices step ] dip
!     ! ( rules state | line pad-n state )
!   swap setup-next
! ] each

! nip 
! sum-state .

[ dup line>> prev-states get ?adjoin ]
[ dup [ line>> string>slices step ] dip
  swap setup-next
] while

dup [ sum-state ] dip
swap [ dup [ line>> string>slices step ] dip swap setup-next sum-state ] dip dup [ - ] dip swap

50000000000 prev-states get length - * + .
drop
! 20 prev-states get length mod prev-states get nth sum-state .
! 50000000000 prev-states get length mod prev-states get nth sum-state .
