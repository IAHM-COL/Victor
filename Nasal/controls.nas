
# Victor controls

var dimmer = func(prop,a) {
	     var rotary = props.globals.getNode("/controls/rotary/"~prop);
		 var setting = rotary.getValue();
		 var newsetting = 0;
		 if ( a == 1 ) {
		     if ( setting != 1 ) { newsetting = ( setting + 0.1 ) };
			 if ( setting == 1 ) { newsetting = 1 };
			}
		 if ( a == 0 ) {
		     if ( setting != 0 ) { newsetting = ( setting - 0.1 ) };
			 if ( setting == 0 ) { newsetting = 0 };
			}
		 interpolate(rotary, newsetting, 0.5);
		 # rotary.setValue(newsetting);
		}
				
		
var enginePanel = {
     EngineStartButton: func(n) {
	     
		 var button = props.globals.getNode("controls/buttons/overhead/engine-starter");
		 var state = button.getBoolValue();
		 
		 if ((state) and (n)) {
		     button.setBoolValue(0);
			}
			
		 if ((!state) and (n)) {
		     button.setBoolValue(1);
			 settimer( me.ButtonLoop, 0.7 );
		    }
		
		},
	
     ButtonLoop: func {
		      
	     var sips = 0;
	     
		 var button = props.globals.getNode("controls/buttons/overhead/engine-starter");
		 var engines = props.globals.getNode("engines").getChildren("engine");
		 foreach ( e ; engines ) {
		     if ( e.getIndex() < 5 ) {
		     var sip = e.getNode("start-in-progress").getBoolValue();
		         #print("Checking engine "~ e.getIndex() ~".");
				 if ( sip ) {
			         sips = ( sips + 1 );
					    }
				    }
			    }
		 #print("Sips: "~ sips );	
  		 
		 if ( sips > 0 ) {
		     button.setBoolValue(1);
			 settimer( func { enginePanel.ButtonLoop(); }, 0.5);
			}
		 else {
		     button.setBoolValue(0);
			}
		 
		},
		
	};
		 

      
