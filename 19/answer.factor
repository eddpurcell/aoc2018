USING: kernel namespaces words math math.functions math.parser accessors ;
USING: io io.files io.encodings.utf8 ;
USING: sequences arrays regexp splitting ; 
USE: prettyprint

IN: time-asm

SYMBOL: r0
SYMBOL: r1
SYMBOL: r2
SYMBOL: r3
SYMBOL: r4
SYMBOL: r5
SYMBOL: regs
{ r0 r1 r2 r3 r4 r5 } regs set

SYMBOL: ip
0 ip set
SYMBOL: ip-reg

: ip> ( -- ) ip get ip-reg get set ;
: >ip ( -- ) ip-reg get ip set ;

: set-regs ( init -- ) regs get [ set ] 2each ;
: get-regs ( -- regs ) regs get ;
: get-regs-values ( -- ns ) regs get [ get ] map ;
: get-reg ( n -- reg ) get-regs nth ; inline

: runr ( ...C quot -- ) swap [ [ [ get-reg get ] dip get-reg get ] dip call ] dip ; inline
: runi ( ...C quot -- ) swap [ [ get-reg get ] 2dip call ] dip ; inline
: runir ( ...C quot -- ) swap [ [ get-reg get ] dip call ] dip ; inline

: addr ( A B C -- ) [ + ] runr get-reg set ; inline
: addi ( A B C -- ) [ + ] runi get-reg set ; inline
: mulr ( A B C -- ) [ * ] runr get-reg set ; inline
: muli ( A B C -- ) [ * ] runi get-reg set ; inline
: banr ( A B C -- ) [ bitand ] runr get-reg set ; inline
: bani ( A B C -- ) [ bitand ] runi get-reg set ; inline
: borr ( A B C -- ) [ bitor ] runr get-reg set ; inline
: bori ( A B C -- ) [ bitor ] runi get-reg set ; inline
: setr ( A B C -- ) nip [ get-reg get ] dip get-reg set ; inline
: seti ( A B C -- ) nip get-reg set ; inline
: gtir ( A B C -- ) [ > [ 1 ] [ 0 ] if ] runir get-reg set ; inline
: gtri ( A B C -- ) [ > [ 1 ] [ 0 ] if ] runi get-reg set ; inline
: gtrr ( A B C -- ) [ > [ 1 ] [ 0 ] if ] runr get-reg set ; inline
: eqir ( A B C -- ) [ = [ 1 ] [ 0 ] if ] runir get-reg set ; inline
: eqri ( A B C -- ) [ = [ 1 ] [ 0 ] if ] runi get-reg set ; inline
: eqrr ( A B C -- ) [ = [ 1 ] [ 0 ] if ] runr get-reg set ; inline

: !ip-reg ( str -- ) R/ \d/ first-match string>number regs get nth ip-reg set ;

: set-ip-reg ( -- ) ip get ip-reg get set ;
: set-ip ( -- ) ip-reg get get ip set ;

: curr-instruction ( program -- instruction ) [ ip get ] dip nth ;

TUPLE: instruction op a b c ;
: <instruction> ( op a b c -- instruction ) instruction boa ;
: execute-instruction ( instruction -- ) dup op>> [ [ a>> ] [ b>> ] [ c>> ] tri ] dip execute( A B C -- ) ;


: run-instruction ( program -- ) set-ip-reg
                                 curr-instruction execute-instruction
                                 ip-reg get get 1 + ip-reg get set set-ip ;

: ip-oor? ( program -- ? ) length ip get <= ;

: run-program ( program -- program ) [ dup ip-oor? ] [ dup run-instruction ] do until ;

"/Users/edd.purcell/projects/aoc2018/19/input.txt" utf8 file-lines unclip
!ip-reg
[ " " split dup first "time-asm" lookup-word swap [ second string>number ] [ third string>number ] [ fourth string>number ] tri <instruction> ] map

{ 0 0 0 0 0 0 } set-regs
0 ip set
run-program
get-regs-values .
drop

: factors ( n -- seq ) dup sqrt >integer <iota> [ 1 + over over / dup integer? [ 2array ] [ 2drop { } ] if ] map harvest nip ;
: program-fast ( n -- n' ) factors [ [ first ] [ second ] bi + ] map-sum ;

950 program-fast .
10551350 program-fast .
