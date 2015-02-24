
# Settings
var stepTime = 1.5; # Time between each step, before delay, in seconds

props.globals.initNode("/sim/autostart/step", 0, "INT");

var ctrls = props.globals.getNode("controls");
var buttons = ctrls.getNode("buttons");
var switches = ctrls.getNode("switches");
var instruments = props.globals.getNode("instrumentation");
var light = props.globals.getNode("sim/time/sun-angle-rad");

var startbutton = func { controls.enginePanel.EngineStartButton(1); } # Bug Fix

# View Changer

# Useage: view( view number, heading, pitch, fov )

 var view = func(n,heading,pitch,fov )  {
     var current = props.globals.getNode("/sim/current-view");
	 if ( n != nil ) { current.getNode("view-number").setValue(n); }
	 if ( heading != nil ) { interpolate( current.getNode("goal-heading-offset-deg"), heading, 2); }
	 if ( pitch != nil ) { interpolate( current.getNode("goal-pitch-offset-deg"), pitch, 2); }
	 if ( fov != nil ) { interpolate(  current.getNode("field-of-view"), fov, 2); }
	}
	
var startEngine = func(a) {
	 settimer ( func { setprop("/controls/switches/overhead/engine-ignition", 1); }, 1);
	 settimer ( func { setprop("/controls/switches/overhead/engine-select["~a~"]", 1); }, 3);
	 settimer ( startbutton, 4.5);
	}

 var num=0; var name=1; var go=2; var delay=3; var alert=4;
 
 var power = [
     [0,"null",0,-1.5,"Executing Power-Up checklist..."],
     [1,"Batteries on",func {
	     view(9, , , ,);
	     ctrls.getNode("electrical/circuit-breakers/port-lv-battery").setBoolValue(1);
		 ctrls.getNode("electrical/circuit-breakers/starboard-lv-battery").setBoolValue(1);
		},0,0],
	 [2,"Starting AAPP",func {
	     view(9, 205, -8, 72.83);
         settimer( func { switches.getNode("AEOs/AAPP-intake").setBoolValue(1); },1.5);
		 settimer( func { genpanel.aapp_start_cover(); }, 5.5);
		 settimer( func { genpanel.aapp_start_switch(); }, 6.5);
         settimer( func { switches.getNode("AEOs/AAPP-load").setBoolValue(1); }, 32);
		 settimer( func { genpanel.aapp_start_cover(); }, 40);

		},3,0],
	];

var engineStart = [	
     [0,"null",0,-1,"Executing Engine Start checklist..."],
	 [1,"LP Cocks open",func {
		 view(0, -64, -42, 68.17);
		 ctrls.getNode("engines/engine[0]/LP-cock").setBoolValue(1);
		 settimer( func { ctrls.getNode("engines/engine[1]/LP-cock").setBoolValue(1); }, 0.75);
		 settimer( func { ctrls.getNode("engines/engine[2]/LP-cock").setBoolValue(1); }, 1.5);
		 settimer( func { ctrls.getNode("engines/engine[3]/LP-cock").setBoolValue(1); }, 2.25);
	    },1.5,0], 
	 [2,"Engine 1 Start",func {
	     view(0, 298, 34, 68.17);
		 settimer ( func { setprop("/controls/switches/overhead/engine-start-master", 1); }, 2);
		 settimer( func { startEngine(0); }, 3 );
		 settimer( func { view(0, -40, -18, 57.77) }, 8 );
		},5.5,1],
	 [3,"Engine 2 Start",func {
		 settimer ( func { setprop("/controls/switches/overhead/engine-start-master", 1); }, 2);
		 settimer( func { startEngine(1); }, 3 );
		},55,1],
	 [4,"Engine 3 Start",func {
		 settimer ( func { setprop("/controls/switches/overhead/engine-start-master", 1); }, 2);
		 settimer( func { startEngine(2); }, 3 );
		},110,1],
	];
	
var combusterStart = [	
     [0,"null",0,-1,"Executing Engine Start checklist..."],
	 [1,"LP Cocks open",func {
		 ctrls.getNode("engines/engine[0]/LP-cock").setBoolValue(1);
		 settimer( func { ctrls.getNode("engines/engine[1]/LP-cock").setBoolValue(1); }, 0.75);
		 settimer( func { ctrls.getNode("engines/engine[2]/LP-cock").setBoolValue(1); }, 1.5);
		 settimer( func { ctrls.getNode("engines/engine[3]/LP-cock").setBoolValue(1); }, 2.25);
	    },0.5,0], 
	 [2,"Engine Start",func {
	     avionics.ctrls.engineStart(1);
		},5.5,0],
	];
	
var taxi = [
     [0,"null",0,-1,"Executing Taxi checklist..."],
	 [1,"Navigation lights on",func {
	     switches.getNode("navigation-lights").setBoolValue(1);
		},1,0],
	 [2,"Arm Ejection Seat", func {
	     pos = ctrls.getNode("seat/arming-handle").getValue();
		 if ( pos != 1 ) {
		     avionics.ctrls.armSeat();
			};}, 1.75,0],
	 [3,"Taxi Lights on",func {
	     var lx = light.getValue();
		 if ( lx > 1.55 ) {
		     avionics.ctrls.gearLights(3);
			}
		},3,0],
	];
	
var takeoff = [
     [0,"null",0,0,"Executing Take-off checklist..."],
	 [1,"Strobes on",func {
	     switches.getNode("strobe-lights").setBoolValue(1);
		},-1,0],
	 [2,"Landing Lights on",func {
		 avionics.ctrls.gearLights(1);
	    },1,0],
	 [3,"Master Armament Safety Switch on",func { # Conditional: Weapons Loaded
		 var stations = props.globals.getNode("computers/weapons/stores");
	     var bvraam = stations.getNode("BVRAAM").getValue();
		 var mraam = stations.getNode("MRAAM").getValue();
		 var sraam = stations.getNode("SRAAM").getValue();
		 var smoke = stations.getNode("smoke").getBoolValue();
		 if (( bvraam + mraam + sraam > 0) and (!smoke)) {
		     avionics.ctrls.MASStoggle();
		    };
	    },1,0],
	 [4,"Canard Unpark",func {
		 props.globals.getNode("systems/FCS/internal/canard-park").setBoolValue(0);
	    },0,0],
	];
	
var autostart = func(n) {
	     screen.log.write("Auto starting");
	     group.power();
		 if ( n == "normal" ) { settimer( func { group.engineStart(); }, 42); }
	     if ( n == "fast" ) { settimer( func { group.combustorStart(); }, 42); }
		 #settimer( func { group.taxi(); }, 50);	     
     	}   
	
var group = {
     power: func {
    	 foreach (x; power) {
	         var delay = x[3];
		     var alert = x[4];
		     var timer = ( stepTime + delay );
		     var name = x[1];
		     var num = x[0];
		 print("Running... "~name~" - Timer: "~timer);
		 if ( x[2] != 0 ) {
		     settimer( x[2], timer);
		     }
		 if ( alert != 0 ) {
		     screen.log.write(alert);
			}
		 }
	     setprop("/sim/autostart/step", 1);
	},
	engineStart: func {
    	 foreach (x; engineStart) {
	         var delay = x[3];
		     var alert = x[4];
		     var timer = ( stepTime + delay );
		     var name = x[1];
		     var num = x[0];
		 print("Running... "~name~" - Timer: "~timer);
		 if ( x[2] != 0 ) {
		     settimer( x[2], timer);
		     }
		 if ( alert != 0 ) {
		     screen.log.write(alert);
			}
		 }
		 setprop("/sim/autostart/step", 2);
	},
	taxi: func {
    	 foreach (x; taxi) {
	         var delay = x[3];
		     var alert = x[4];
		     var timer = ( stepTime + delay );
		     var name = x[1];
		     var num = x[0];
		 print("Running... "~name~" - Timer: "~timer);
		 if ( x[2] != 0 ) {
		     settimer( x[2], timer);
		     }
		 if ( alert != 0 ) {
		     screen.log.write(alert);
			}
		 }
		 setprop("/sim/autostart/step", 3);
	},
	takeoff: func {
    	 foreach (x; takeoff) {
	         var delay = x[3];
		     var alert = x[4];
		     var timer = ( stepTime + delay );
		     var name = x[1];
		     var num = x[0];
		 print("Running... "~name~" - Timer: "~timer);
		 if ( x[2] != 0 ) {
		     settimer( x[2], timer);
		     }
		 if ( alert != 0 ) {
		     screen.log.write(alert);
			}
		 }
		 setprop("/sim/autostart/step", 4);
	}
}

