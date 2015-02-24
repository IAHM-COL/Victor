
# aeo-gen-panel.nas
# AEO's Electrical Generator Panel - Handley Page Victor B/K 2

	 var controls = props.globals.getNode("controls");
     var switches = controls.getNode("switches/AEOs");

var alt_switch = func(altnum, pos) {
    var x = (altnum - 1);
	var knob = switches.getNode("engine-alternator["~x~"]");
	interpolate(knob, pos, 0.3);
   
     var breakers = props.globals.getNode("/controls/electrical/circuit-breakers");
     var abreaker = breakers.getNode("a-breaker["~x~"]");
	 var sbreaker = breakers.getNode("s-breaker["~x~"]");
	
     if  ( pos == 1 ) {
	     abreaker.setBoolValue(1); 
		}
	 if ( pos == 0 ) {
	     abreaker.setBoolValue(0);
		}
	 if ( pos == -1 ) {
	     print("Reset Breaker " ~ x ~ "!");
	    }
	 if ( pos == 2 ) {
	     sbreaker.setBoolValue(0);
		}
    }
	
var elec = props.globals.getNode("/systems/electrical");
var gauge_path = props.globals.getNode("/sim/model/victor/cockpit/AEO-panel/gauges", 1);
	
var gauges = [
     { vprop: "outputs/busbars/port-busbar", animprop: "port-mv-busbar" },
	 { vprop: "outputs/busbars/starboard-busbar", animprop: "starboard-mv-busbar" },
	 { vprop: "outputs/busbars/port-lv-busbar", animprop: "port-lv-busbar" },
	 { vprop: "outputs/busbars/starboard-lv-busbar", animprop: "starboard-lv-busbar" },
	 { vprop: "outputs/AAPP/AAPP-generator-meter", animprop: "AAPP-generator" },
	];
     
var gauge_anim = func {
     foreach(gauge; gauges) {
	     var volts = elec.getNode(gauge.vprop).getValue();
		 var anim = gauge_path.getNode(gauge.animprop, 1);
		 var reading = anim.getValue();
		 interpolate(anim, volts, 0.35);
		}
	 settimer(gauge_anim, 0.15);
	}

settimer(gauge_anim, 10);

var aapp_load = func {
     var state = getprop("/controls/switches/AEOs/AAPP-load");
	 if ( state ) {
	     setprop("/controls/engines/AAPP/throttle", 0.65);
		}
	 else {
	     setprop("/controls/engines/AAPP/throttle", 0);
		}
	}
	
setlistener("/controls/switches/AEOs/AAPP-load", aapp_load);

var aapp_in = func {
     var state = getprop("/controls/switches/AEOs/AAPP-intake");
	 if ( state ) {
	     victor.aapp_intake.open();
		}
	 else {
	     victor.aapp_intake.close();
		}
	}

setlistener("/controls/switches/AEOs/AAPP-intake", aapp_in);

var aapp_start_cover = func {
     var cover = props.globals.getNode("/controls/switches/AEOs/AAPP-start-cover");
	 if ( cover.getValue() == 0 ) { interpolate(cover, 1, 0.3); }
	 if ( cover.getValue() == 1 ) { interpolate(cover, 0, 0.3); }
	}
	
var aapp_start_switch = func {
     var cover = props.globals.getNode("/controls/switches/AEOs/AAPP-start-cover").getValue();
	 var switch = props.globals.getNode("/controls/switches/AEOs/AAPP-start");
	 var switchstate = switch.getBoolValue();
	 if ( cover == 1 ) {
	     if ( !switchstate ) { 
		     switch.setBoolValue(1);
             engines.startAAPP();			 
			}
		 else { switch.setBoolValue(0); 
		     engines.stopAAPP();
		    }
		}
	}
	
var init = func {
     settimer( func {
         gen_panel_loop();
	    },10);
    }	 

setlistener("/sim/signals/fdm-initialized", init);

	
var gen_panel_loop = func {

     var suppliers = props.globals.getNode("/systems/electrical/suppliers");
	 
	 # AAPP Relay
	 
	 var aappV = suppliers.getNode("AAPP-alternator").getValue(); 
	 var relay = props.globals.getNode("/controls/electrical/relays/AAPP");
	 
	 if ( aappV < 190 ) { relay.setBoolValue(0); }
	 if ( aappV > 190 ) { 
	 
	     var busbars = props.globals.getNode("/systems/electrical/outputs/busbars");
		 var breakers = props.globals.getNode("/controls/electrical/circuit-breakers");

		 var bus1 = busbars.getNode("engine-busbar[0]").getValue();
		 var bus2 = busbars.getNode("engine-busbar[1]").getValue();
		 var bus3 = busbars.getNode("engine-busbar[2]").getValue();
		 var bus4 = busbars.getNode("engine-busbar[3]").getValue();
		 var sbr1 = breakers.getNode("s-breaker[0]").getValue();
		 var sbr2 = breakers.getNode("s-breaker[0]").getValue();
		 var sbr3 = breakers.getNode("s-breaker[0]").getValue();
		 var sbr4 = breakers.getNode("s-breaker[0]").getValue();

		 
		 var ground = suppliers.getNode("ground-power-200V").getValue();
		 var gndbrk = breakers.getNode("ground-power-mv").getBoolValue();
		 var parallel = breakers.getNode("parallel-mv-busbars").getBoolValue();
		 
		 
		 var portvolts = 0;
		 var stbdvolts = 0;	
         var totalvolts = 0;		 
		 
		 if ( ( bus1 > 0.5 ) and (sbr1) ) { portvolts = portvolts + 1; }
		 if ( ( bus2 > 0.5 ) and (sbr2) ) { portvolts = portvolts + 1; }
		 if ( ( bus3 > 0.5 ) and (sbr3) ) { stbdvolts = stbdvolts + 1; }
		 if ( ( bus4 > 0.5 ) and (sbr4) ) { stbdvolts = stbdvolts + 1; }
		 if ( ( ground > 0.5 ) and (gndbrk) ) { portvolts = portvolts + 1; }
		 
		 totalvolts = stbdvolts;
		 if (parallel) { totalvolts = totalvolts + portvolts }

		 if ( totalvolts > 0 ) { relay.setBoolValue(0); }
		 if ( totalvolts == 0 ) { relay.setBoolValue(1); }
		 
		 #Debug
         #print("Port: "~portvolts~" / Stbd: "~stbdvolts~" / Total: "~totalvolts );
	    
		}
		
     settimer(gen_panel_loop, 0.5);
	
	}

