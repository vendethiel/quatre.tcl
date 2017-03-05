proc run {code} {
  # default-init the stack
  lappend stack

  # set up commands
  set commands(print) {{text} {
    puts $text
  }}
  set commands(+) {{a b} {
    upvar 1 stack
    expr $a+$b
  }}

  # run code
  foreach el $code {
    if {[info exists commands($el)]} {
      set cmd $commands($el)
      # get arglen for the apply
      set arglen [llength [lindex $cmd 0]]
      # 0-indexed lists
      incr arglen -1
      # reverse list: top of stack is 1st arg
      set lambdarg [lreverse [lrange $stack end-$arglen end]]
      set stack [lrange $stack 0 end-[expr $arglen+1]]
      lappend stack [apply $cmd {*}$lambdarg]
    } else {
      # XXX lappend *might* fuck up braces in that list.. :(
      #     (after testing: should not happen if a braced value
      #      wasn't in the first `set`)
      lappend stack $el
    }
  }
}

while {![eof stdin]} {
  run [gets stdin]
}
