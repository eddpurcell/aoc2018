USING: kernel accessors math math.order sequences vectors arrays sets sorting io ;
USE: prettyprint

IN: particle-messages

TUPLE: particle { x integer } { y integer } { dx integer read-only } { dy integer read-only } ;
: <particle> ( x y dx dy -- particle ) particle boa ;
: move ( particle -- ) dup x>> over dx>> + >>x dup y>> over dy>> + swap y<< ;

: particle-xs ( particles -- xs ) [ x>> ] map members ;
: particle-ys ( particles -- ys ) [ y>> ] map members ;
: particles-in-row ( y particles -- particles' ) [ y>> over = ] filter nip ;
: particles-in-col ( x particles -- particles' ) [ x>> over = ] filter nip ;
: sort-by-x ( particles -- particles' ) [ [ x>> ] dip x>> <=> ] sort ;
: sort-by-y ( particles -- particles' ) [ [ y>> ] dip y>> <=> ] sort ;
: group-particles-x ( particles -- seq-particles ) 
  sort-by-x unclip 1vector 1vector swap [ 
    over last last x>> 1 + over x>> =
    [ over last push ]
    [ 1vector over push ]
    if
  ] each ;
: group-particles-y ( particles -- seq-particles ) 
  sort-by-y unclip 1vector 1vector swap [ 
    over last last y>> 1 + over y>> =
    [ over last push ]
    [ 1vector over push ]
    if
  ] each ;
: particles-in-hline? ( n particles -- ? ) dup particle-ys [ over particles-in-row group-particles-x [ length ] map supremum pick >= ] filter length 0 > 2nip ;
: particles-in-vline? ( n particles -- ? ) dup particle-xs [ over particles-in-col group-particles-y [ length ] map supremum pick >= ] filter length 0 > 2nip ;

: minmax ( seq -- min max ) dup infimum swap supremum ;
: print-particles ( particles -- ) dup particle-ys minmax over - 1 + <iota> [ over + ] map nip [
    over particles-in-row particle-xs 
    over particle-xs minmax over - 1 + <iota> [ over + ] map nip 
    [
      over in? [ "#" write ] [ "." write ] if
    ] each drop
    "\n" write
  ] each drop ;

{ }
11118 -32416 -1 3 <particle> 1array append
43666 43652 -4 -4 <particle> 1array append
21928 54518 -2 -5 <particle> 1array append
54535 -32422 -5 3 <particle> 1array append
54586 -54155 -5 5 <particle> 1array append
43670 54514 -4 -5 <particle> 1array append
43690 -10686 -4 1 <particle> 1array append
32807 -10680 -3 1 <particle> 1array append
21924 -32420 -2 3 <particle> 1array append
54549 -21547 -5 2 <particle> 1array append
-32367 43654 3 -4 <particle> 1array append
21941 -32416 -2 3 <particle> 1array append
-32379 21915 3 -2 <particle> 1array append
32791 43649 -3 -4 <particle> 1array append
54569 -21555 -5 2 <particle> 1array append
-21520 -10687 2 1 <particle> 1array append
-43230 11055 4 -1 <particle> 1array append
11110 -32420 -1 3 <particle> 1array append
-54101 -32418 5 3 <particle> 1array append
-21512 -43288 2 4 <particle> 1array append
32835 11053 -3 -1 <particle> 1array append
-32362 43647 3 -4 <particle> 1array append
21943 21922 -2 -2 <particle> 1array append
43658 32786 -4 -3 <particle> 1array append
-32391 32789 3 -3 <particle> 1array append
43678 -10679 -4 1 <particle> 1array append
-43234 -43287 4 4 <particle> 1array append
32799 32785 -3 -3 <particle> 1array append
43666 11053 -4 -1 <particle> 1array append
-21531 11047 2 -1 <particle> 1array append
-10624 21913 1 -2 <particle> 1array append
43690 -54150 -4 5 <particle> 1array append
-10627 -10679 1 1 <particle> 1array append
11076 43656 -1 -4 <particle> 1array append
32848 -21555 -3 2 <particle> 1array append
-43276 11046 4 -1 <particle> 1array append
-10627 21918 1 -2 <particle> 1array append
-21512 11049 2 -1 <particle> 1array append
-54140 21913 5 -2 <particle> 1array append
-54101 11048 5 -1 <particle> 1array append
-21536 -21547 2 2 <particle> 1array append
43671 21914 -4 -2 <particle> 1array append
32847 21921 -3 -2 <particle> 1array append
43658 -43288 -4 4 <particle> 1array append
21941 -54150 -2 5 <particle> 1array append
-43270 11055 4 -1 <particle> 1array append
-21483 32787 2 -3 <particle> 1array append
-32411 -32421 3 3 <particle> 1array append
32819 43655 -3 -4 <particle> 1array append
21956 21917 -2 -2 <particle> 1array append
-54085 -21555 5 2 <particle> 1array append
21948 54515 -2 -5 <particle> 1array append
-54127 32780 5 -3 <particle> 1array append
-10621 -54151 1 5 <particle> 1array append
-21544 -43280 2 4 <particle> 1array append
-54124 -54155 5 5 <particle> 1array append
-32359 -32422 3 3 <particle> 1array append
-10669 54518 1 -5 <particle> 1array append
-54094 32780 5 -3 <particle> 1array append
-32358 -21546 3 2 <particle> 1array append
-21544 21920 2 -2 <particle> 1array append
-54092 -10688 5 1 <particle> 1array append
-32391 11049 3 -1 <particle> 1array append
43661 32780 -4 -3 <particle> 1array append
-10673 -54156 1 5 <particle> 1array append
-54117 -10680 5 1 <particle> 1array append
32792 43651 -3 -4 <particle> 1array append
-10673 54518 1 -5 <particle> 1array append
11113 -10682 -1 1 <particle> 1array append
54534 32780 -5 -3 <particle> 1array append
32835 21913 -3 -2 <particle> 1array append
-10677 -32416 1 3 <particle> 1array append
-32403 -54149 3 5 <particle> 1array append
-10669 54515 1 -5 <particle> 1array append
-21487 54523 2 -5 <particle> 1array append
-54084 43655 5 -4 <particle> 1array append
-10626 21922 1 -2 <particle> 1array append
54530 -10688 -5 1 <particle> 1array append
43677 -43285 -4 4 <particle> 1array append
43702 11049 -4 -1 <particle> 1array append
-32379 32785 3 -3 <particle> 1array append
11105 -10680 -1 1 <particle> 1array append
-21494 43647 2 -4 <particle> 1array append
43658 -10683 -4 1 <particle> 1array append
21985 -32413 -2 3 <particle> 1array append
-21508 -43280 2 4 <particle> 1array append
21981 21913 -2 -2 <particle> 1array append
21943 11046 -2 -1 <particle> 1array append
11076 54518 -1 -5 <particle> 1array append
-10643 54523 1 -5 <particle> 1array append
11109 54523 -1 -5 <particle> 1array append
-43254 -32420 4 3 <particle> 1array append
21924 32783 -2 -3 <particle> 1array append
-43266 -54152 4 5 <particle> 1array append
-21507 54523 2 -5 <particle> 1array append
-21511 -43280 2 4 <particle> 1array append
11102 -54156 -1 5 <particle> 1array append
32842 43656 -3 -4 <particle> 1array append
-43234 -32416 4 3 <particle> 1array append
21924 21913 -2 -2 <particle> 1array append
-21526 -54151 2 5 <particle> 1array append
-43257 54514 4 -5 <particle> 1array append
54545 54517 -5 -5 <particle> 1array append
-43225 32781 4 -3 <particle> 1array append
54527 -32422 -5 3 <particle> 1array append
-10645 -32414 1 3 <particle> 1array append
-21512 -43282 2 4 <particle> 1array append
-10629 -10681 1 1 <particle> 1array append
32841 43647 -3 -4 <particle> 1array append
-54134 11050 5 -1 <particle> 1array append
54577 54514 -5 -5 <particle> 1array append
-32403 -32421 3 3 <particle> 1array append
21924 -54149 -2 5 <particle> 1array append
-21525 32789 2 -3 <particle> 1array append
11116 -43284 -1 4 <particle> 1array append
-54101 -10680 5 1 <particle> 1array append
32847 11050 -3 -1 <particle> 1array append
54538 11047 -5 -1 <particle> 1array append
54569 11052 -5 -1 <particle> 1array append
54566 32789 -5 -3 <particle> 1array append
-43235 21922 4 -2 <particle> 1array append
11115 32789 -1 -3 <particle> 1array append
-43238 -21548 4 2 <particle> 1array append
54586 43656 -5 -4 <particle> 1array append
-10645 -43284 1 4 <particle> 1array append
-32383 43648 3 -4 <particle> 1array append
43669 -54156 -4 5 <particle> 1array append
-32387 43650 3 -4 <particle> 1array append
21966 -43280 -2 4 <particle> 1array append
-10674 11050 1 -1 <particle> 1array append
-32385 -32419 3 3 <particle> 1array append
32847 -21548 -3 2 <particle> 1array append
-32395 21913 3 -2 <particle> 1array append
32840 -21549 -3 2 <particle> 1array append
32847 43651 -3 -4 <particle> 1array append
-32363 -32413 3 3 <particle> 1array append
54583 54523 -5 -5 <particle> 1array append
21942 -32422 -2 3 <particle> 1array append
43661 -21555 -4 2 <particle> 1array append
-21536 -21550 2 2 <particle> 1array append
-21493 -43285 2 4 <particle> 1array append
-21535 -43289 2 4 <particle> 1array append
11065 -32416 -1 3 <particle> 1array append
21967 11046 -2 -1 <particle> 1array append
11113 11047 -1 -1 <particle> 1array append
43690 32784 -4 -3 <particle> 1array append
-10621 -10681 1 1 <particle> 1array append
-32379 43648 3 -4 <particle> 1array append
54581 43649 -5 -4 <particle> 1array append
-54085 -10683 5 1 <particle> 1array append
-10674 21917 1 -2 <particle> 1array append
-32355 -54148 3 5 <particle> 1array append
-54085 -32417 5 3 <particle> 1array append
-54087 -32422 5 3 <particle> 1array append
-43218 -32414 4 3 <particle> 1array append
11057 -21546 -1 2 <particle> 1array append
-21536 43649 2 -4 <particle> 1array append
-32351 -43281 3 4 <particle> 1array append
11077 32783 -1 -3 <particle> 1array append
21949 11051 -2 -1 <particle> 1array append
-54110 54523 5 -5 <particle> 1array append
11081 -32417 -1 3 <particle> 1array append
-43254 21919 4 -2 <particle> 1array append
32843 21916 -3 -2 <particle> 1array append
54578 -54155 -5 5 <particle> 1array append
-43217 -32421 4 3 <particle> 1array append
-54101 54519 5 -5 <particle> 1array append
-10669 32782 1 -3 <particle> 1array append
11113 -21547 -1 2 <particle> 1array append
-21526 54523 2 -5 <particle> 1array append
21985 -32415 -2 3 <particle> 1array append
-32409 32784 3 -3 <particle> 1array append
43711 32782 -4 -3 <particle> 1array append
21981 -54147 -2 5 <particle> 1array append
-10667 54518 1 -5 <particle> 1array append
54541 54521 -5 -5 <particle> 1array append
11078 54523 -1 -5 <particle> 1array append
-43269 -54156 4 5 <particle> 1array append
32799 54517 -3 -5 <particle> 1array append
-43262 -21547 4 2 <particle> 1array append
-43218 -21555 4 2 <particle> 1array append
-43257 43649 4 -4 <particle> 1array append
-32379 -43280 3 4 <particle> 1array append
-32379 -54149 3 5 <particle> 1array append
-32363 32787 3 -3 <particle> 1array append
-32399 32784 3 -3 <particle> 1array append
-54089 54515 5 -5 <particle> 1array append
-54132 -10685 5 1 <particle> 1array append
-10621 11049 1 -1 <particle> 1array append
-43258 54514 4 -5 <particle> 1array append
-43234 21914 4 -2 <particle> 1array append
43675 -10679 -4 1 <particle> 1array append
32802 11046 -3 -1 <particle> 1array append
-32385 21919 3 -2 <particle> 1array append
32792 54514 -3 -5 <particle> 1array append
54533 43656 -5 -4 <particle> 1array append
43716 43647 -4 -4 <particle> 1array append
43690 -43289 -4 4 <particle> 1array append
-21485 21922 2 -2 <particle> 1array append
-54121 32789 5 -3 <particle> 1array append
-43268 -43285 4 4 <particle> 1array append
-32411 -32413 3 3 <particle> 1array append
-43234 32788 4 -3 <particle> 1array append
11101 -43288 -1 4 <particle> 1array append
-43268 -21555 4 2 <particle> 1array append
-43217 -21549 4 2 <particle> 1array append
54533 -21555 -5 2 <particle> 1array append
-54135 11046 5 -1 <particle> 1array append
-43236 54523 4 -5 <particle> 1array append
21927 -21555 -2 2 <particle> 1array append
-54145 -21551 5 2 <particle> 1array append
11085 -54148 -1 5 <particle> 1array append
-10653 21914 1 -2 <particle> 1array append
54566 43656 -5 -4 <particle> 1array append
-32362 -43280 3 4 <particle> 1array append
-10629 43647 1 -4 <particle> 1array append
-21495 32786 2 -3 <particle> 1array append
-32354 21922 3 -2 <particle> 1array append
-54089 54521 5 -5 <particle> 1array append
54542 -32413 -5 3 <particle> 1array append
54577 -32419 -5 3 <particle> 1array append
11065 -21546 -1 2 <particle> 1array append
-54112 21922 5 -2 <particle> 1array append
-10656 21914 1 -2 <particle> 1array append
11077 -43289 -1 4 <particle> 1array append
32803 -43285 -3 4 <particle> 1array append
32847 -54152 -3 5 <particle> 1array append
32823 43654 -3 -4 <particle> 1array append
11118 -32417 -1 3 <particle> 1array append
-43219 -43284 4 4 <particle> 1array append
-54112 -54147 5 5 <particle> 1array append
-54105 21920 5 -2 <particle> 1array append
32850 21913 -3 -2 <particle> 1array append
32791 -21547 -3 2 <particle> 1array append
54549 11053 -5 -1 <particle> 1array append
-54113 -32419 5 3 <particle> 1array append
-21486 21913 2 -2 <particle> 1array append
-10653 11055 1 -1 <particle> 1array append
43671 -43287 -4 4 <particle> 1array append
54549 54521 -5 -5 <particle> 1array append
-32353 -43280 3 4 <particle> 1array append
-32379 -54150 3 5 <particle> 1array append
-10677 54517 1 -5 <particle> 1array append
-21523 43647 2 -4 <particle> 1array append
11106 -21555 -1 2 <particle> 1array append
11109 -54147 -1 5 <particle> 1array append
-21488 43652 2 -4 <particle> 1array append
43667 54518 -4 -5 <particle> 1array append
-21483 11047 2 -1 <particle> 1array append
-32360 43651 3 -4 <particle> 1array append
-54109 -32413 5 3 <particle> 1array append
-54113 -10686 5 1 <particle> 1array append
-54128 -32413 5 3 <particle> 1array append
32804 -43287 -3 4 <particle> 1array append
-32395 54523 3 -5 <particle> 1array append
-10645 -10683 1 1 <particle> 1array append
21952 -32421 -2 3 <particle> 1array append
11065 -32422 -1 3 <particle> 1array append
-43243 -43280 4 4 <particle> 1array append
-43222 -43286 4 4 <particle> 1array append
43674 43655 -4 -4 <particle> 1array append
-43238 43654 4 -4 <particle> 1array append
21985 -54149 -2 5 <particle> 1array append
32808 -54156 -3 5 <particle> 1array append
-54105 54522 5 -5 <particle> 1array append
21951 -32420 -2 3 <particle> 1array append
-21519 54518 2 -5 <particle> 1array append
11081 -43289 -1 4 <particle> 1array append
43701 54514 -4 -5 <particle> 1array append
21945 -54155 -2 5 <particle> 1array append
-21520 11055 2 -1 <particle> 1array append
43719 -43281 -4 4 <particle> 1array append
-54113 54515 5 -5 <particle> 1array append
43687 11046 -4 -1 <particle> 1array append
-10659 21913 1 -2 <particle> 1array append
21980 -54150 -2 5 <particle> 1array append
-10627 11055 1 -1 <particle> 1array append
21940 -21546 -2 2 <particle> 1array append
43660 -43285 -4 4 <particle> 1array append
-43249 -32413 4 3 <particle> 1array append
-32395 -43289 3 4 <particle> 1array append
-54121 32780 5 -3 <particle> 1array append
-32384 -10681 3 1 <particle> 1array append
43675 43653 -4 -4 <particle> 1array append
54549 -32418 -5 3 <particle> 1array append
54549 -54148 -5 5 <particle> 1array append
43684 -32416 -4 3 <particle> 1array append
43674 -10688 -4 1 <particle> 1array append
-32387 -10680 3 1 <particle> 1array append
-32354 11046 3 -1 <particle> 1array append
-32375 -32413 3 3 <particle> 1array append
11101 11046 -1 -1 <particle> 1array append
11076 -54152 -1 5 <particle> 1array append
54576 43656 -5 -4 <particle> 1array append
-43225 21914 4 -2 <particle> 1array append

0 tuck drop
[ 7 over particles-in-vline? ]
[ swap 1 + swap dup [ move ] each ] do until

print-particles .
