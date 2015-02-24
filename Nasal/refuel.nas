
# Refuel

var boom = {
     extend: func {
	     interpolate("/systems/refuel/arm-position-norm", 1, 10.5);
		},
	 retract: func {
	     interpolate("/systems/refuel/boom-position-norm", 0, 2);
		 interpolate("/systems/refuel/arm-position-norm", 0, 10.5);
		},
	}