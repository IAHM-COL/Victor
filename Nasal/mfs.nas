
# MFS

var update_period = 0.5;
var dhnode = props.globals.getNode("/instrumentation/director-horizon");
var ilsnode = props.globals.getNode("/instrumentation/nav[0]");

flag_speed = 0.25;


var dh = {
     loop: func {
	     #Flags
		 var beamFlag = dhnode.getNode("flags/beam-flag-pos-norm");
		 var gpFlag = dhnode.getNode("flags/gp-flag-pos-norm");
		 var beam = dhnode.getNode("beam-flag");
		 var gp = dhnode.getNode("gp-flag");

		 if ( ( beam.getBoolValue() ) and ( beamFlag.getValue() == 0 ) ) {
		     interpolate(beamFlag, 1, flag_speed);
			} 
		 if ( ( !beam.getBoolValue() ) and ( beamFlag.getValue() == 1 ) ) {
		     interpolate(beamFlag, 0, flag_speed);
			} 
		 if ( ( gp.getBoolValue() ) and ( gpFlag.getValue() == 0 ) ) {
		     interpolate(gpFlag, 1, flag_speed);
			} 
		 if ( ( !gp.getBoolValue() ) and ( gpFlag.getValue() == 1 ) ) {
		     interpolate(gpFlag, 0, flag_speed);
			}

         # Temporary ILS Flag Triggers
		 
		 beam.setBoolValue( ilsnode.getNode("in-range").getBoolValue() );
		 gp.setBoolValue( ilsnode.getNode("gs-in-range").getBoolValue() );
			
		 settimer(dh.loop, update_period);
		},
    };		

dh.loop();