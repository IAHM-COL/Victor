
# External Lights

var landing_lights_extend = func {
     var switch = getprop("/controls/switches/pilots/lights/landing-lights-extend");
	 var volts = getprop("/systems/electrical/outputs/busbars/starboard-busbar");
	 if ( volts > 180 ) { 
	     if ( switch == 0 ) { lights.port_landlight_door.close(); }
		 if ( switch == 2 ) { lights.port_landlight_door.open(); }
		}
	}
	
setlistener("/controls/switches/pilots/lights/landing-lights-extend", landing_lights_extend);