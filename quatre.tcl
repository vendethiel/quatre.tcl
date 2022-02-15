proc debug {x} {
  #puts $x
}

proc run {code} {
  # default-init the stack
  lappend stack

  # set up commands
  set commands(print) {{text} {
    puts $text
    list
  }}
  set commands(+) {{a b} {
    expr $a+$b
  }}
  set commands(join2) {{a b} {
    list [list $a $b]
  }}
  set commands(split) {{xs} {
    return $xs
  }}
  set commands(length) {{xs} {
    llength $xs
  }}
  set commands(dup) {{x} {
    list $x $x
  }}

  # run code
  foreach el $code {
    if {[info exists commands($el)]} {
      set cmd $commands($el)
      # get arglen for the apply
      set arglen [llength [lindex $cmd 0]]
      # 0-indexed lists
      incr arglen -1
      debug "Pre stack: $stack"
      # reverse list: top of stack is 1st arg
      set lambdarg [lreverse [lrange $stack end-$arglen end]]
      set stack [lrange $stack 0 end-[expr $arglen+1]]
      set stack [concat $stack [apply $cmd {*}$lambdarg]]
      debug "Post stack: $stack"
    } else {
      debug "Pre append: $stack"
      lappend stack $el
      debug "Post append: $stack"
    }
  }
}

while {![eof stdin]} {
  run [gets stdin]
}
