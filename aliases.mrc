op { massmode $1 +o $$2- }
dop { massmode $1 -o $$2- }
deop { massmode $1 -o $$2- }
voice { massmode $1 +v $$2- }
vo { massmode $1 +v $$2- }
dvoice { massmode $1 -v $$2- }
dvo { massmode $1 -v $$2- }
devoice { massmode $1 -v $$2- }
/j /join #$$1 $2-
p { part $1- }
part { !part $iif($left($1,1) isin $chantypes,$1 $iif($2,$2-,-namIRC-),$active $iif($1,$1-,-namIRC-)) }
/n /names #$$1
/k /kick # $$1 $2-
/q /query $$1
/send /dcc send $1 $2
/chat /dcc chat $1
/ping /ctcp $$1 ping
/s /server $$1-
w { whois $$1 }
ew { whois $$1 $$1 }
who {
  if (!$show) { set -se %who.hide. [ $+ [ $cid ] $+ ] . [ $+ [ $$1 ] ] 1 }
  !who $$1-
}

whois {
  if (!$show) { set -se %whois.hide. [ $+ [ $cid ] $+ ] . [ $+ [ $$1 ] ] 1 }
  if (!$1) && ($window($active).type == query) { whois $active }
  else { !whois $$1- }
}

massmode {
  while ($3) {
    mode $1 $left($2,1) $+ $str($right($2,1),$modespl) $gettok($3-,1- $+ $modespl $+ ,32)
    tokenize 32 $1-2 $gettok($3-, $+ $calc($modespl + 1) $+ -,32)
  }
}

fupper { return $+($upper($left($1,1)),$right($1,-1)) }

daychange { scon -a echoall -teg It's a new day! ( $+ $day $+ ) }
echoall {
  ;Echo in Status
  echo -steg $1-
  
  ;Echo all Chans
  var %c = $chan(0)
  while (%c) { echo $iif($left($1,1) == -,$1 $chan(%c) $2-,-teg $chan(%c) $1-) | dec %c }
  
  ;Echo all Querys
  var %q = $query(0)
  while (%q) { echo $iif($left($1,1) == -,$1 $query(%q) $2-,-teg $query(%q) $1-) | dec %q }
}

settings {
  ;$settings()
  ;$settings(section,item) -
  if (!$1) { return $qt($mircdir\settings.ini) }
  if ($2) && ($readini($qt($mircdir\settings.ini),$1,$2)) { return $readini($qt($mircdir\settings.ini),$1,$2) }
  else { return $false }
}

spacing {
  ;return a word with spaces
  ;$spacing(example,32) would return "e x a m p l e"
  var %a = 1
  while (%a <= $len(%s)) { var %w = $instok(%w,$mid($1,%a,1),%a,$2) | inc %a }
  return %w
}

oper {
  ;$oper(network,nick || *!*@*) - return true if address is an irc operator
  if ($isid) {
    if ($+(oper.,$1) iswm $ial($2,1).mark) { return $true }
    else { return $false }  
  }
}

comchans {
  var %a = 1
  while (%a <= $comchan($1,0)) { var %c = $addtok(%c,$comchan($1,%a),32) | inc %a } 
  return %c
}

redirect {
  ;$redirect(event)
  if ($isid) {
    if ($readini(settings.ini,redirect,$1)) { return $true }
  }
  ;/redirect event color text
  else {
    if ($3) {
      if ($readini(settings.ini,redirect,$1) == 1) { window $+(-e2k0n,$iif($1 == whois,z)) $+(@,$fupper($1)) }
      ;echo $2 -tl $iif($readini(bin\settings.ini,redirect,$1) == 1,$+(@,$1),$iif($readini(bin\settings.ini,redirect,$1) == 2,-a,-s)) $3-
      if ($3 == !end!) { echo $2 -l $+(@,$1) $chr(160) }
      else { echo $2 -tl $+(@,$1) $3- }
    }
  }
}
