
# Settings
var stepTime = 1.5; # Time between each step, before delay, in seconds

props.globals.initNode("/sim/autostart/step", 0, "INT");

var ctrls = props.globals.getNode("controls");
var buttons = ctrls.getNode("buttons");
var switches = ctrls.getNode("switches");
var instruments = props.globals.getNode("instrumentation");
var light = props.globals.getNode("sim/time/sun-angle-rad");

var startbutton = func { controls.enginePanel.EngineStartButton(1); } # Bug Fix

var asnode = props.globals.initNode("/sim/autostart/autostarted", 0, "BOOL");

# View Changer

# Useage: view( view number, heading, pitch, fov )

 var view = func(n,heading,pitch,fov )  {
     var enabled = getprop("/preferences/view-follows-autostart");
	 if (enabled) {
	     var current = props.globals.getNode("/sim/current-view");
	     if ( n != nil ) { current.getNode("view-number").setValue(n); }
	     if ( heading != nil ) { interpolate( current.getNode("goal-heading-offset-deg"), heading, 2); }
	     if ( pitch != nil ) { interpolate( current.getNode("goal-pitch-offset-deg"), pitch, 2); }
	     if ( fov != nil ) { interpolate(  current.getNode("field-of-view"), fov, 2); }
	    }
	}
	
var startEngine = func(a) {
	 settimer ( func { setprop("/controls/switches/overhead/engine-ignition", 1); }, 1);
	 settimer ( func { setprop("/controls/switches/overhead/engine-select["~a~"]", 1); }, 3);
	 settimer ( startbutton, 4.5);
	 settimer ( func { setprop("/controls/switches/overhead/engine-select["~a~"]", 0); }, 54);
	}
	

 var num=0; var name=1; var go=2; var delay=3; var alert=4;
 
 var power = [
     [0,"null",0,-1.5,"Executing Power-Up checklist..."],
     [1,"Batteries on",func {
	     view(9, , , ,);
	     ctrls.getNode("electrical/circuit-breakers/port-lv-battery").setBoolValue(1);
		 ctrls.getNode("electrical/circuit-breakers/starboard-lv-battery").setBoolValue(1);
		},0,""],
	 [2,"Beacon on", func {
	     switches.getNode("pilots/lights/beacon").setBoolValue(1);
		},0,""],
	 [3,"Starting AAPP",func {
	     view(9, 205, -8, 72.83);
         settimer( func { switches.getNode("AEOs/AAPP-intake").setBoolValue(1); },1.5);
		 settimer( func { genpanel.aapp_start_cover(); }, 5.5);
		 settimer( func { genpanel.aapp_start_switch(); }, 6.5);
         settimer( func { switches.getNode("AEOs/AAPP-load").setBoolValue(1); }, 32);
		 settimer( func { genpanel.aapp_start_cover(); }, 40);

		},3,"Starting AAPP"],
	];

var engineStart = [	
     [0,"null",0,-1,"Executing Engine Start checklist..."],
	 [1,"LP Cocks open",func {
		 view(0, -64, -42, 64.17);
		 ctrls.getNode("engines/engine[0]/LP-cock").setBoolValue(1);
		 settimer( func { ctrls.getNode("engines/engine[1]/LP-cock").setBoolValue(1); }, 0.75);
		 settimer( func { ctrls.getNode("engines/engine[2]/LP-cock").setBoolValue(1); }, 1.5);
		 settimer( func { ctrls.getNode("engines/engine[3]/LP-cock").setBoolValue(1); }, 2.25);
	    },1.5,0], 
	 [2,"Engine 1 Start",func {
	     view(0, 298, 34, 68.17);
		 settimer ( func { setprop("/controls/switches/overhead/engine-start-master", 1); }, 2);
		 settimer( func { startEngine(0); }, 3 );
		 settimer( func { view(0, 320, -18, 57.77) }, 9 );
		},5.5,1],
	 [3,"Engine 2 Start",func {
		 view(0, 298, 34, 68.17);
		 settimer ( func { setprop("/controls/switches/overhead/engine-start-master", 1); }, 2);
		 settimer( func { startEngine(1); }, 3 );
		 settimer( func { view(0, 320, -18, 57.77) }, 9 );
		},55,1],
	 [4,"Engine 3 Start",func {
	     view(0, 298, 34, 68.17);
		 settimer ( func { setprop("/controls/switches/overhead/engine-start-master", 1); }, 2);
		 settimer( func { startEngine(2); }, 3 );
		 settimer( func { view(0, 320, -18, 57.77) }, 9 );
		},110,1],
	 [4,"Engine 4 Start",func {
	     view(0, 298, 34, 68.17);
		 settimer ( func { setprop("/controls/switches/overhead/engine-start-master", 1); }, 2);
		 settimer( func { startEngine(3); }, 3 );
		 settimer( func { view(0, 320, -18, 57.77) }, 9 );
		},165,1],
	 [5,"Ignition Switch Off, Start Master to Flight",func {
	     view(0, 298, 34, 68.17);
		 settimer ( func { setprop("/controls/switches/overhead/engine-ignition", 0); }, 3.5);
		 settimer ( func { setprop("/controls/switches/overhead/engine-start-master", 3); }, 5);
		},220,0],
	];
	
var combustorStart = [	
     [0,"null",0,-1,"Executing Combustor Start checklist..."],
     [1,"LP Cocks open",func {
		 view(0, -64, -42, 64.17);
		 ctrls.getNode("engines/engine[0]/LP-cock").setBoolValue(1);
		 settimer( func { ctrls.getNode("engines/engine[1]/LP-cock").setBoolValue(1); }, 0.75);
		 settimer( func { ctrls.getNode("engines/engine[2]/LP-cock").setBoolValue(1); }, 1.5);
		 settimer( func { ctrls.getNode("engines/engine[3]/LP-cock").setBoolValue(1); }, 2.25);
	    },1.5,0], 
	 [2,"Engine Start",func {
	     view(0, 298, 34, 68.17);
		 settimer ( func { setprop("/controls/switches/overhead/engine-start-master", 0); }, 2);
		 settimer( func { 
		     switches.getNode("overhead/engine-ignition").setBoolValue(1);
		     switches.getNode("overhead/engine-select[0]").setBoolValue(1);
			 switches.getNode("overhead/engine-select[1]").setBoolValue(1);
			 switches.getNode("overhead/engine-select[2]").setBoolValue(1);
			 switches.getNode("overhead/engine-select[3]").setBoolValue(1);
			}, 4 );
		 settimer ( func { startbutton(); }, 5.5);
		 settimer( func { view(0, 320, -18, 57.77) }, 7 );
		},5.5,1],	
	 [5,"Ignition Switch Off, Start Master to Flight",func {
	     view(0, 298, 34, 68.17);
		 settimer ( func {
		     switches.getNode("overhead/engine-select[0]").setBoolValue(0);
			 switches.getNode("overhead/engine-select[1]").setBoolValue(0);
			 switches.getNode("overhead/engine-select[2]").setBoolValue(0);
			 switches.getNode("overhead/engine-select[3]").setBoolValue(0);
			},1.5);
		 settimer ( func { setprop("/controls/switches/overhead/engine-ignition", 0); }, 3.5);
		 settimer ( func { setprop("/controls/switches/overhead/engine-start-master", 3); }, 5);
		},100,0],
	];
	
var PFCUs = [
     [0,"null",0,-1,"Executing Powered Flying Control Units checklist..."],
	 [1,"PFCUs on",func {
	     view(0, -44, -13, 57.7);
	     var pfcuswitches = switches.getNode("pilots/powered-surfaces/");
		 settimer( func { 
		     pfcuswitches.getNode("aileron-port[0]").setBoolValue(1); 
			 pfcuswitches.getNode("aileron-stbd[0]").setBoolValue(1); 
		}, 1);
		 settimer( func { 
		     pfcuswitches.getNode("aileron-port[1]").setBoolValue(1); 
			 pfcuswitches.getNode("aileron-stbd[1]").setBoolValue(1); 
		}, 1.75);
		 settimer( func { 
		     pfcuswitches.getNode("rudder-port").setBoolValue(1); 
			 pfcuswitches.getNode("rudder-stbd").setBoolValue(1); 
		}, 2.5);
	 	 settimer( func { 
		     pfcuswitches.getNode("elevator-port[0]").setBoolValue(1); 
			 pfcuswitches.getNode("elevator-stbd[0]").setBoolValue(1); 
		}, 3.25);
	 	 settimer( func { 
		     pfcuswitches.getNode("elevator-port[1]").setBoolValue(1); 
			 pfcuswitches.getNode("elevator-stbd[1]").setBoolValue(1); 
		}, 4);
	},1,0],
	];



var taxi = [
     [0,"null",0,-1,"Executing Taxi checklist..."],
     [1,"External Lights On", func {
	     setprop("/controls/switches/pilots/lights/nav-lights", 1);
		 var lx = getprop("sim/time/sun-angle-rad");
		 if ( lx > 1.55 ) {
		     setprop("/controls/switches/pilots/lights/landing-lights-extend", 2);
			 setprop("/controls/switches/pilots/lights/landing-light-port", 1);
		     setprop("/controls/switches/pilots/lights/landing-light-starboard", 1);
			}
		},1,""],
	 [0,"Close Crew Door",func {
	     interpolate("/controls/doors/cockpit-door-pos-norm", 0, 5);
		},5,"Closing Crew Door"],
	];
	
var takeoff = [
     [0,"null",0,0,"Executing Take-off checklist..."],

	];
	
var shutdown = [
     [0,"null",0,0,"Executing Shutdown checklist..."],
     [0,"LP Cocks Off", func {
	     setprop("/controls/switches/pilots/lights/landing-lights-extend", 0);
	     setprop("/controls/switches/pilots/lights/landing-light-port", 0);
		 setprop("/controls/switches/pilots/lights/landing-light-starboard", 0);
	     setprop("/controls/switches/pilots/lights/nav-lights", 0);
		 setprop("/controls/switches/overhead/engine-ignition", 0);
	     ctrls.getNode("engines/engine[0]/LP-cock").setBoolValue(0);
		 ctrls.getNode("engines/engine[1]/LP-cock").setBoolValue(0);
		 ctrls.getNode("engines/engine[2]/LP-cock").setBoolValue(0);
		 ctrls.getNode("engines/engine[3]/LP-cock").setBoolValue(0);
		 settimer( func { switches.getNode("AEOs/AAPP-load").setBoolValue(0); }, 3);
		 settimer( func { genpanel.aapp_start_cover(); }, 5.5);
		 settimer( func { genpanel.aapp_start_switch(); }, 6.5);
         settimer( func { switches.getNode("pilots/lights/beacon").setBoolValue(0); }, 35);
	 },12,""],
	];
	
var autostart = func(n) {
	     if ( !asnode.getBoolValue() ) {
		     screen.log.write("Auto starting");
		     asnode.setBoolValue(1);
			 group.power();
		     if ( n == "normal" ) { settimer( func { group.engineStart(); }, 42); }
	         if ( n == "fast" ) { settimer( func { group.combustorStart(); }, 30); }
		     #settimer( func { group.PFCUs(); }, 50);
		     settimer( func { group.taxi(); }, 95);
			}
		 else {
		     screen.log.write("Auto shutting down");
			 asnode.setBoolValue(0);
		     group.shutdown();
     	}
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
	combustorStart: func {
    	 foreach (x; combustorStart) {
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
	PFCUs: func {
    	 foreach (x; PFCUs) {
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
	},
	shutdown: func {
    	 foreach (x; shutdown) {
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
		 setprop("/sim/autostart/step", 0);
	},
}

