
# Rembrandt Lighting Package
# Modelled for FlightGear by Algernon Aerospace

print("Initialising external lights...");

# Variables
var speed = 1.2;
var power_path = "/systems/electrical/outputs/ext-lights/beacon"; # Path to 28V DC supply
var rotate_path = "/sim/model/lights/beacon"; # Path to beacon rotation property for animation
var strobe_path = "/sim/model/lights/strobe"; # Path to strobe
var anim_path = "/sim/model/lights/beacon/rotation";
var refuel_path = "/sim/model/lights/refuelling";

	 props.globals.initNode(rotate_path, 0, "DOUBLE");
	 props.globals.initNode(power_path, 0, "DOUBLE");
	 props.globals.initNode(anim_path, 0, "DOUBLE");
	 aircraft.light.new(rotate_path, [1.2, 1.2], power_path);
	 aircraft.light.new(strobe_path, [0.05, 2.2], power_path);
	 aircraft.light.new((refuel_path~"/green"), [0.8,0.8], "controls/switches/AEOs/lights/refuelling-green");
	 aircraft.light.new((refuel_path~"/yellow"), [0.8,0.8], "controls/switches/AEOs/lights/refuelling-yellow");
	 aircraft.light.new((refuel_path~"/red"), [0.8,0.8], "controls/switches/AEOs/lights/refuelling-red");

var trigger = props.globals.getNode("/sim/model/lights/beacon/state");
	 
var init = func {
	 setlistener(trigger, rotate);
	 dayadj();
	 var port_landlight_door = aircraft.door.new ("/sim/model/lights/landing-lights/port/", 6, 1); # Flap for Each Door
     var stbd_landlight_door = aircraft.door.new ("/sim/model/lights/landing-lights/starboard/", 6, 1);
	}
	
# Daylight Adjuster

props.globals.initNode("/sim/model/lights/daylight-adjuster", 0.2, "DOUBLE");
var dayadj = func {
	 var rad = getprop("/sim/time/sun-angle-rad");
	 var fact = ((( 1 / rad ) * 1.4) - 0.25);
	 setprop("/sim/model/lights/daylight-adjuster", fact);
	 settimer(dayadj, 0.5);
	 }
	
var rotate = func {
	 var state = trigger.getBoolValue();
	 if ( state ) { interpolate(anim_path, 1, speed); }
     if ( !state ) { interpolate(anim_path, 0, speed); }
    } 	 
	
setlistener("/sim/signals/fdm-initialized", init);

# Landing Lights



	 





