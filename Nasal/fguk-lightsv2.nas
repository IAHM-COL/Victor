
#
### -= FGUK Lighting Pack (Rembrandt) V2.0 -= ###
###
### by Algernon Aerospace
#


# Setup:

# 1. Choose a property tree branch to locate the animation properties in
# --
var modelpath = "/sim/model/lights";

# 2. Choose the first of four sequential available properties in your /sim/multiplay/generic/int branch
# e.g. change to 3 to use int[3], int[4], int[5] and int[6]
# --
var firstmpprop = 3;

# 3. Set the property tree branch where the voltage outputs are located
#--
var powerpath = "/systems/electrical/outputs/ext-lights/";

# 4. Change the following settings if appropriate
# --
var req_voltage = 28; # Volts required by lamp (+/- 2v tolerance)
var update_period = 0.2; # Monitor loop speed - increase to loop less frequently & help framerates
var beacon_speed = 1.2; # Rotation speed of Grimes beacon

#####

	 var models = props.globals.getNode(modelpath);
	 var models_props = models.getChildren();
	 
	 var trigger = ( modelpath~"/beacon/state");

var init = func {
	 models.initNode("nav-lights/powered", 0, "BOOL");
	 models.initNode("landing-light-port/powered", 0, "BOOL");
	 models.initNode("landing-light-starboard/powered", 0, "BOOL");
	 models.initNode("refuelling-lights-centre/powered", 0, "BOOL");
	 models.initNode("refuelling-lights-port/powered", 0, "BOOL");
	 models.initNode("refuelling-lights-starboard/powered", 0, "BOOL");
	 models.initNode("beacon/rotation", 0, "DOUBLE");
	 aircraft.light.new(modelpath~"/strobe", [0.05, 1.8], modelpath~"/strobe/powered");
	 aircraft.light.new(modelpath~"/beacon", [beacon_speed, beacon_speed], modelpath~"/beacon/powered");
	 setlistener("/sim/model/lights/refuelling-lights-centre/green/state", func {
	     bulb("/sim/model/lights/refuelling-lights-centre/green", 0.15);
		});
	 setlistener("/sim/model/lights/refuelling-lights-centre/yellow/state", func {
	     bulb("/sim/model/lights/refuelling-lights-centre/yellow", 0.15);
		});
	 lightloop();
	 dayadj();
	 setlistener( modelpath~"/beacon/state", rotate);
	 setlistener("/controls/switches/AEOs/lights/refuelling-centre/", refuel_lights);
	 
	}

var lightloop = func {
     foreach(b; models_props) {
	     var name = b.getName();
		 if ( name != "daylight-adjuster" ) {
		     var power = props.globals.getNode(powerpath);
             var vnode = power.getNode(name);
		     var volts = vnode.getValue();		 
		     if (( volts > ( req_voltage - 2)) and (volts < ( req_voltage + 2))) {
		         setprop(modelpath ~ "/" ~ name~ "/powered", 1);
			    }
		     else {
		         setprop(modelpath ~ "/" ~ name~ "/powered", 0);
			    }
			}
		}
	settimer(lightloop, update_period);
	}
	
var refuel_lights = func {
     var signal = props.globals.getNode("sim/multiplay/generic/int[8]").getValue();
	 var gstate = props.globals.getNode(refuel_path~"/green/state", 1);
	 var rstate = props.globals.getNode(refuel_path~"/red/state", 1);
	 var ystate = props.globals.getNode(refuel_path~"/yellow/state", 1);
	 
	 if ( signal == 0 ) { 
	     gstate.setBoolValue(0);
		 rstate.setBoolValue(0);
		 ystate.setBoolValue(0);
		}

	 if ( signal == 1) { 
	     gstate.setBoolValue(0);
		 rstate.setBoolValue(0);
		 ystate.setBoolValue(1);
		}
	
	if ( signal == 2 ) { 
	     gstate.setBoolValue(0);
		 rstate.setBoolValue(1);
		 ystate.setBoolValue(0);
		}
	}
	
var bulb = func(node, time) {
     var source = props.globals.getNode(node, 1);
	 var check = source.getNode("illumination");
	 
	 if ( check == nil ) {
	     source.initNode("illumination", 0, "DOUBLE");
		}
		
	var state = source.getNode("state").getBoolValue();
	
	 if (state) {
	     interpolate(source.getNode("illumination"),1,(time*0.85));
		}
	 if (!state) {
	     interpolate(source.getNode("illumination"),0,time);
		}
	}	
	
props.globals.initNode("/sim/model/lights/daylight-adjuster", 0.2, "DOUBLE");
var dayadj = func {
	 var rad = getprop("/sim/time/sun-angle-rad");
	 var fact = ((( 1 / rad ) * 1.4) - 0.25);
	 setprop(modelpath ~ "/daylight-adjuster", fact);
	 settimer(dayadj, 2);
	 }
	
var rotate = func {
     var trigger = models.getNode("beacon/state");
	 var state = trigger.getBoolValue();
	 anim_path = models.getNode("beacon/rotation");
	 if ( state ) { interpolate( anim_path, 1, beacon_speed); }
     if ( !state ) { interpolate(anim_path, 0, beacon_speed); }
    }
	
### Victor Only Stuff

var port_landlight_door = aircraft.door.new ("/sim/model/lights/landing-light-port/", 5); # Flap for Each Door
var stbd_landlight_door = aircraft.door.new ("/sim/model/lights/landing-light-starboard/", 5);

	
settimer(init, 10);