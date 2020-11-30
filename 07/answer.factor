USING: kernel sequences splitting vectors arrays accessors io.files io.encodings.utf8 ;
USING: prettyprint sorting sets io byte-arrays math ;
IN: dependency-graph

TUPLE: dependency id parents children ;
: <dependency> ( -- dependency ) dependency new ;
: sink? ( dependency -- ? ) children>> length 0 = ;
: source? ( dependency -- ? ) parents>> length 0 = ;
: +child ( child parent -- ) children>> push ;
: +parent ( parent child -- ) parents>> push ;
: -parent ( parent children -- ) [ parents>> over swap remove! drop ] each drop ;

: find-or-new ( id seq -- dependency ) [ id>> over = ] find nip dup 
  [ nip ] 
  [ drop <dependency> swap >>id 10 <vector> >>parents 10 <vector> >>children ] if ;

: print-id ( dependency -- dependency ) dup id>> write ;

: sort-dependencies ( dependencies -- dependencies' ) [ id>> ] sort-with ;

V{ }
"input.txt" utf8 file-lines
[
  ">" split1 2array
] map
[
  dup first pick find-or-new ! ( nodes ids parent )
  [ second over find-or-new ] dip ! ( nodes child parent )
  2dup +child 2dup swap +parent
  [ over push ] dip over push
] each

[ source? not ] reject members

! Part 1
[
  dup empty?
]
[
  sort-dependencies
  unclip print-id dup children>> dup [ -parent ] dip
  append
  [ source? not ] reject
] until drop "\n\n" write

! Part 2

: time ( id -- n ) >byte-array first 4 - ;

SYMBOL: met-deps
SYMBOL: duration

FROM: namespaces => set get ;
26 <vector> met-deps set 
0 duration set

TUPLE: worker curr-task time-remaining ;
: <worker> ( -- worker ) worker new ;
: set-task ( worker dependency -- ) dup id>> [ >>curr-task ] dip time >>time-remaining drop ;
: idle-workers ( workers -- newworkers ) [ curr-task>> f = ] filter ;
: active-workers ( workers -- newworkers ) [ curr-task>> f = ] reject ;
: closest-done ( workers -- worker ) active-workers [ time-remaining>> ] infimum-by ;
: update-times ( n workers -- ) active-workers [ dup time-remaining>> pick  - >>time-remaining drop ] each drop ;

: update-children ( dependency -- dependency ) dup dup children>> -parent ;
: next-task ( dependencies -- dependencies' dependency ) sort-dependencies unclip ;
: queue-children ( queue children -- queue' ) append members [ dup source? not swap met-deps get in? or ] reject ;

V{ }
"input.txt" utf8 file-lines
[
  ">" split1 2array
] map
[
  dup first pick find-or-new ! ( nodes ids parent )
  [ second over find-or-new ] dip ! ( nodes child parent )
  2dup +child 2dup swap +parent
  [ over push ] dip over push
] each

[ source? not ] reject members
5 <vector> 5 [ dup 0 > ] [ <worker> pick push 1 - ] while drop swap

[ dup empty? pick idle-workers length 5 = and ]
[ ! ( workers sources )
  over idle-workers dup empty? pick empty? or
  [
    drop over closest-done ! ( workers sources worker )
    dup time-remaining>> dup duration get + duration set swap [ pick update-times ] dip ! ( workers sources worker )
    dup curr-task>> swap f >>curr-task drop print-id ! ( workers sources dependency )
    update-children children>> queue-children ! ( workers sources )
  ]
  [
    first swap next-task dup met-deps get push rot swap set-task ! ( workers sources )
  ] if
] until 2drop "\n" write
duration get .
