
# Mk10 Autopilot

var controls = props.globals.getNode("/instrumentation/mk10-autopilot");

var bankselector = controls.getNode("bank-selector");
var engage_switch = controls.getNode("engage-switch");
	
var disengage = func {
     setprop("/instrumentation/mk10-autopilot/engaged-switch", 0);
	}
	 
var hlock_lstn = func {	 
     var pselpos = getprop("/instrumentation/mfs-selector/pitch-selector-pos");
	 if ( pselpos == -1 ) {
	     var alt = getprop("/position/altitude-ft");
	     setprop("/systems/mk10-autopilot/height-lock", alt);
		}
	}
	
var bankselect = func(n) {
     interpolate(bankselector, n, 1.0);
	}
	 
setlistener("/instrumentation/mfs-selector/pitch-selector-pos", hlock_lstn);