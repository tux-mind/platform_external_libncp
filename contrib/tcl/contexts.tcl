#!/usr/bin/tixwish
#############################################################################
# Visual Tcl v1.20 Project
#
# NDSutils library
#   called by ncplogin.tcl to get the list of visible contexts under a tree
#    Copyright (C) 2001 by Patrick Pollet
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


#    Revision history:

#        1.00  January      1999           Patrick Pollet
#                Initial version using Caldera NDS client
#        1.1   February     2001           Patrick Pollet
#                adapted for ncpfs NDS client

#################################
# GLOBAL VARIABLES
#


#################################
# USER DEFINED PROCEDURES
#
proc init {argc argv} {
}

init $argc $argv



proc uponelevel {} {
global context
  set dot [string first "." $context]
  if { $dot == "-1" } {
      set context ""
  } else {
     set context [string range $context [ expr $dot +1] [expr [string length $context]-1]]
  }
     readcontexts
}


proc chgcontext {nctx} {
global context
  if {$nctx != ".."} {
     if {$context !=""} {
             set context $nctx.$context
     } else {
             set context $nctx
     }
     readcontexts
 } else {
     uponelevel
 }
}


proc doValidate {} {
global context
global NDS
     set NDS(context) $context
     grab release .top51
     destroy .top51
}

proc doSelect {} {
global context

  catch { .top51.cpd53.01 curselection} num
  if { $num != "-1" } {
        catch { .top51.cpd53.01  get $num} sel
        if { $sel == ".." } {
           uponelevel
        } else {
              chgcontext $sel
        }
  }
}


proc {readcontexts} {} {
global context
global tree

  if {$context == "" } {
    catch {exec ncplist -T $tree -v 4 -Q -l "Org*" } ctxs
 } else {
     catch {exec ncplist -T $tree  -v 4 -Q -A -o $context -c $context -l "Org*" } ctxs
 }
 set ctxs [lsort $ctxs]
 .top51.cpd53.01 delete 0 end

 if {$context !=""} {
   .top51.cpd53.01 insert end ".."
 }
 foreach ctx $ctxs {
        .top51.cpd53.01 insert end $ctx
  }
}


proc {main} {argc argv} {
global tree
global context
global NDS
   #set tree $NDS(tree)
   #set context $NDS(context)
  readcontexts
}

proc {Window} {args} {
global vTcl
    set cmd [lindex $args 0]
    set name [lindex $args 1]
    set newname [lindex $args 2]
    set rest [lrange $args 3 end]
    if {$name == "" || $cmd == ""} {return}
    if {$newname == ""} {
        set newname $name
    }
    set exists [winfo exists $newname]
    switch $cmd {
        show {
            if {$exists == "1" && $name != "."} {wm deiconify $name; return}
            if {[info procs vTclWindow(pre)$name] != ""} {
                eval "vTclWindow(pre)$name $newname $rest"
            }
            if {[info procs vTclWindow$name] != ""} {
                eval "vTclWindow$name $newname $rest"
            }
            if {[info procs vTclWindow(post)$name] != ""} {
                eval "vTclWindow(post)$name $newname $rest"
            }
        }
        hide    { if $exists {wm withdraw $newname; return} }
        iconify { if $exists {wm iconify $newname; return} }
        destroy { if $exists {destroy $newname; return} }
    }
}

#################################
# VTCL GENERATED GUI PROCEDURES
#

proc vTclWindow. {base} {
    if {$base == ""} {
        set base .
    }
    ###################
    # CREATING WIDGETS
    ###################
    wm focusmodel $base passive
    wm geometry $base 1x1+0+0
    wm maxsize $base 1137 834
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm withdraw $base
    wm title $base "vt.tcl"
    ###################
    # SETTING GEOMETRY
    ###################
}

proc vTclWindow.top51 {base} {
global STR
    if {$base == ""} {
        set base .top51
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel \
        -menu .top51.m28 
    wm focusmodel $base passive
    wm geometry $base 453x290+163+164
    wm maxsize $base 1137 834
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 0 0
    wm deiconify $base
    wm title $base $STR(pick_ctx)
    button $base.but52 \
        -activeforeground blue -command doValidate \
        -font -Adobe-Helvetica-*-R-Normal--*-120-*-*-*-*-*-* -padx 9 -pady 3 \
        -text $STR(ok)
    frame $base.cpd53 \
        -height 30 -relief sunken -width 30
    listbox $base.cpd53.01 \
        -font -Adobe-Helvetica-Medium-R-Normal-*-*-120-*-*-*-*-*-* -height 0 \
        -width 0 -xscrollcommand {.top51.cpd53.02 set} \
        -yscrollcommand {.top51.cpd53.03 set}
    bind $base.cpd53.01 <Double-Button-1> {
        doSelect
    }
    scrollbar $base.cpd53.02 \
        -borderwidth 1 -command {.top51.cpd53.01 xview} -orient horiz \
        -width 0
    scrollbar $base.cpd53.03 \
        -borderwidth 1 -command {.top51.cpd53.01 yview} -orient vert \
        -width 10
    button $base.but55 \
        -activeforeground blue -command { destroy .top51 } \
        -font -Adobe-Helvetica-*-R-Normal--*-120-*-*-*-*-*-* -padx 9 -pady 3 \
        -text $STR(cancel)
    label $base.lab58 \
        -image logo -relief sunken -text  Logo
    menu $base.m28 \
        -cursor {}
    label $base.lab29 \
        -borderwidth 1 -justify left -relief raised  \
       -textvariable context
    ###################
    # SETTING GEOMETRY
    ###################
    place $base.but52 \
        -x 355 -y 110 -width 92 -height 26 -anchor nw -bordermode ignore
    place $base.cpd53 \
        -x 5 -y 105 -width 340 -height 180 -anchor nw -bordermode ignore
    grid columnconf $base.cpd53 0 -weight 1
    grid rowconf $base.cpd53 0 -weight 1
    grid $base.cpd53.01 \
        -in .top51.cpd53 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.cpd53.02 \
        -in .top51.cpd53 -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky ew 
    grid $base.cpd53.03 \
        -in .top51.cpd53 -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns 
    place $base.but55 \
        -x 355 -y 160 -width 92 -height 26 -anchor nw -bordermode ignore 
    place $base.lab58 \
        -x 5 -y 5 -width 446 -height 77 -anchor nw -bordermode ignore 
    place $base.lab29 \
        -x 5 -y 85 -width 331 -height 18 -anchor nw -bordermode ignore 
}

Window show .
Window show .top51

main $argc $argv
