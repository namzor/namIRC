raw *:*:{
  ;ISON
  if ($numeric == 303) {
    if (%ison.hide. [ $+ [ $cid ] $+ ] . [ $+ [ $hash($2,32) ] ]) { haltdef }
       
    set -es %retake.free. [ $+ [ $cid ] ] $remove(%retake. [ $+ [ $cid ] ], [ $replace($2,$chr(32),$chr(44)) ] )
    if ($numtok(%retake.free. [ $+ [ $cid ] ],32)) { tnick $gettok(%retake.free. [ $+ [ $cid ] ],1,32) }
  }
 
  ;433 <nickname> :Nickname is already in use.
  if ($numeric == 433) {
    if ($istok(%retake.free. [ $+ [ $cid ] ],$2,32)) {
      if (%retake.free. [ $+ [ $cid ] ]) {
        tnick $gettok(%retake.free. [ $+ [ $cid ] ],1,32)
        set -es %retake.free. [ $+ [ $cid ] ] $deltok(%retake.free. [ $+ [ $cid ] ],1,32)
      }
    }
    retake $2 $iif($2 == $mnick,1,$iif($2 == $anick,2))
    retake
  }
 
  ;437 <nick> :Nick/channel is temporarily unavailable
  if ($numeric == 437) && ($istok(%retake. [ $+ [ $cid ] ],$2,32)) { .timerretake. [ $+ [ $cid ] ] 0 15 tnick $2 }
 
}
 
on *:PARSELINE:*:*:{
  var %a = $remove($parseline,$chr(10))
 
  if ($parsetype == out) {
    if ($gettok(%a,1,32) === NICK) { set -seu30 %nickchange. [ $+ [ $cid ] ] $addtok(%nickchange. [ $+ [ $cid ] ],$mid($gettok(%a,2,32),2),32) }
  }
 
  elseif ($parsetype == in) {
    if ($gettok(%a,2,32) === NICK) {
      var -s %m = $mid($gettok($gettok(%a,1,32),1,33),2)
      var -s %n = $mid($gettok(%a,3,32),2)
 
      if (%m == $me) {
        if ($istok(%nickchange. [ $+ [ $cid ] ],0,32)) && ($network == ircnet) { set -se %nickchange. [ $+ [ $cid ] ] $reptok(%nickchange. [ $+ [ $cid ] ],0,%n,0,32) }
        if ($istok(%nickchange. [ $+ [ $cid ] ],%n,32)) {
          if ($remtok(%nickchange. [ $+ [ $cid ] ],%n,0,32)) { set -se %nickchange. [ $+ [ $cid ] ] $remtok(%nickchange. [ $+ [ $cid ] ],%n,0,32) }
          else { unset %nickchange. [ $+ [ $cid ] ] }
 
          ;RETAKE PART
          if ($istok(%retake. [ $+ [ $cid ] ],%n,32)) {
            if ($findtok(%retake. [ $+ [ $cid ] ],%n,1,32) == 1) || ($numtok(%retake. [ $+ [ $cid ] ],%n,32) == 1) {
              unset -s %retake. [ $+ [ $cid ] ] %retake.free. [ $+ [ $cid ] ]
              timerretake. [ $+ [ $cid ] ] off
            }
            else { set -se %retake. [ $+ [ $cid ] ] $deltok(%retake. [ $+ [ $cid ] ],$findtok(%retake. [ $+ [ $cid ] ],%n,32),32) }
          }
 
        }
        else {
          ;;;Forced Nick Change
          if (%autonickchange. [ $+ [ $cid ] ] < 3) {
            set -eku10 %autonickchange. [ $+ [ $cid ] ] $calc(%autonickchange. [ $+ [ $cid ] ] +1)
            tnick $me
          }
        }
      }
    }
  }
}
 
alias retake {
  ;/retake <nick> <N>
  if (!$1) { .ison %retake. [ $+ [ $cid ] ] }
  else {
    if (!$istok(%retake. [ $+ [ $cid ] ],$1,32)) { set -es %retake. [ $+ [ $cid ] ] $iif($2 isnum,$instok(%retake. [ $+ [ $cid ] ],$1,$2,32),$addtok(%retake. [ $+ [ $cid ] ],$1,32)) }
  }
}
 
alias ison {
  if (!$show) { set -seu10 %ison.hide. [ $+ [ $cid ] $+ ] . [ $+ [ $hash($$1,32) ] ] 1 }
  !ison $$1-
}
