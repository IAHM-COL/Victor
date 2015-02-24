
#Radios

#ILS

var instr = props.globals.getNode("instrumentation");
var sbox = props.globals.getNode("controls/station-box");

instr.initNode("nav[0]/volume",0,"DOUBLE");
instr.initNode("nav[0]/static-volume",0,"DOUBLE");

var ils = {
     loop: func {
	     if ( instr.getNode("nav[0]/operable").getBoolValue() ) {
		     var sbswitch = sbox.getNode("ils").getBoolValue();
			 var sbvol = sbox.getNode("volume").getValue();
			 var ilssig = instr.getNode("nav[0]/signal-quality-norm").getValue();
			 var ilsvol = instr.getNode("nav[0]/volume");
			 var ilsstatic = instr.getNode("nav[0]/static-volume");
			 var staticvol = ( ( ilssig * -1 ) + 1.05 );
			 ilsstatic.setValue( staticvol );
			 
			 if ( sbswitch ) { 
			     ilsvol.setValue( ilssig * ( sbvol -0.2 ) ); 
				}
			 else { ilsvol.setValue(0); }
			}
		 settimer(ils.loop, 0.2);
		},
	};
	
var rt = {
     loop: func {
	 if ( instr.getNode("comm[0]/operable").getBoolValue() ) {
	     var sbswitch = sbox.getNode("rt1").getBoolValue();
		 var sbvol = sbox.getNode("volume").getValue();
		 var rt1vol = instr.getNode("comm[0]/volume");
		 if ( sbswitch ) { 
			     rt1vol.setValue( sbvol + 0.2 ); 
				}
			 else { rt1vol.setValue(0); }
		    }
     if ( instr.getNode("comm[1]/operable").getBoolValue() ) {
	     var sbswitch = sbox.getNode("rt2").getBoolValue();
		 var sbvol = sbox.getNode("volume").getValue();
		 var rt2vol = instr.getNode("comm[1]/volume");
		 if ( sbswitch ) { 
			     rt2vol.setValue( sbvol + 0.2 ); 
				}
			 else { rt2vol.setValue(0); }
		    }
		 settimer(rt.loop, 0.25);
	     },
     init: func {
	     var numofchans = 0;
		 print("Initialising RT Channel List");
		 settimer(rt.loop,1);
		},
	 chan: func(n) {
		     var channels = instr.getNode("comm-channels");
			 var sel = instr.getNode("comm["~n~"]/channel-selected").getValue();
			 var chan = channels.getNode("channel["~sel~"]");
			 var id = chan.getNode("id").getValue();
			 var freq = chan.getNode("frequency").getValue();
			 setprop("/instrumentation/comm["~n~"]/channel-id", id);
			 setprop("/instrumentation/comm["~n~"]/frequencies/selected-mhz", freq);
		},
	 xmit: func() {
	     var pos = sbox.getNode("xmit").getValue();
        },		 
	};

settimer(ils.loop,4);
settimer(rt.init,5);




