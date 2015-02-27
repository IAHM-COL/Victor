# generic-yasim-engine.nas -- a generic Nasal-based engine control system for YASim
# Version 1.0.0
#
# Copyright (C) 2011  Ryan Miller
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

var UPDATE_PERIOD = 0; # update interval for engine init() functions

# jet engine class
var Jet =
{
	# creates a new engine object
	new: func(n, running = 0, idle_throttle = 0.01, max_start_n1 = 5.21, start_threshold = 3, spool_time = 4, start_time = 0.02, shutdown_time = 4)
	{
		# copy the Jet object
		var m = { parents: [Jet] };
		# declare object variables
		m.number = n;
		m.autostart_status = 0;
		m.autostart_id = -1;
		m.loop_running = 0;
		m.started = 0;
		m.starting = 0;
		m.idle_throttle = idle_throttle;
		m.max_start_n1 = max_start_n1;
		m.start_threshold = start_threshold;
		m.spool_time = spool_time;
		m.start_time = start_time;
		m.shutdown_time = shutdown_time;
		# create references to properties and set default values
		m.cutoff = props.globals.getNode("controls/engines/engine[" ~ n ~ "]/cutoff", 1);
		m.cutoff.setBoolValue(!running);
		m.n1 = props.globals.getNode("engines/engine[" ~ n ~ "]/n1", 1);
		m.n1.setDoubleValue(0);
		m.out_of_fuel = props.globals.getNode("engines/engine[" ~ n ~ "]/out-of-fuel", 1);
		m.out_of_fuel.setBoolValue(0);
		m.reverser = props.globals.getNode("controls/engines/engine[" ~ n ~ "]/reverser", 1);
		m.reverser.setBoolValue(0);
		m.rpm = props.globals.getNode("engines/engine[" ~ n ~ "]/rpm", 1);
		m.rpm.setDoubleValue(running ? 100 : 0);
		m.running = props.globals.getNode("engines/engine[" ~ n ~ "]/running", 1);
		m.running.setBoolValue(running);
		m.serviceable = props.globals.getNode("engines/engine[" ~ n ~ "]/serviceable", 1);
		m.serviceable.setBoolValue(1);
		m.starter = props.globals.getNode("controls/engines/engine[" ~ n ~ "]/starter", 1);
		m.starter.setBoolValue(0);
		m.sip = props.globals.getNode("engines/engine[" ~ n ~ "]/start-in-progress", 1);
        m.sip.setBoolValue();
		m.throttle = props.globals.getNode("controls/engines/engine[" ~ n ~ "]/throttle", 1);
		m.throttle.setDoubleValue(0);
		m.throttle_lever = props.globals.getNode("controls/engines/engine[" ~ n ~ "]/throttle-lever", 1);
		m.throttle_lever.setDoubleValue(0);
		# return our new object
		return m;
	},
	# engine-specific autostart
	autostart: func
	{
		if (me.autostart_status)
		{
			me.autostart_status = 0;
			me.cutoff.setBoolValue(1);
		}
		else
		{
			me.autostart_status = 1;
			me.starter.setBoolValue(1);
			settimer(func
			{
				me.cutoff.setBoolValue(0);
			}, me.max_start_n1 / me.start_time);
		}
	},
	# creates an engine update loop (optional)
	init: func
	{
		if (me.loop_running) return;
		me.loop_running = 1;
		var loop = func
		{
			me.update();
			settimer(loop, UPDATE_PERIOD);
		};
		settimer(loop, 0);
	},
	# updates the engine
	update: func
	{
		if (me.running.getBoolValue() and !me.started)
		{
			me.running.setBoolValue(0);
		}
		
		if ( !me.running.getBoolValue() and me.starter.getBoolValue() ) {
			 
			 if ( ( me.rpm.getValue() > 2 ) and ( me.rpm.getValue() <38 ) ) { 
			     me.sip.setBoolValue(1);
				}
				
			else {
			     me.sip.setBoolValue(0);
			    }
			}
	
		else {
		     me.sip.setBoolValue(0);
		}
		
		if (me.cutoff.getBoolValue() or !me.serviceable.getBoolValue() or me.out_of_fuel.getBoolValue())
		{
			var rpm = me.rpm.getValue();
			var time_delta = getprop("sim/time/delta-realtime-sec");
			if (me.starter.getBoolValue())
			{
				rpm += time_delta * me.spool_time;
				me.rpm.setValue(rpm >= me.max_start_n1 ? me.max_start_n1 : rpm);
			}
			else
			{
				rpm -= time_delta * me.shutdown_time;
				me.rpm.setValue(rpm <= 0 ? 0 : rpm);
				me.running.setBoolValue(0);
				me.throttle_lever.setDoubleValue(0);
				me.started = 0;
			}
		}
		elsif (me.starter.getBoolValue())
		{
			var rpm = me.rpm.getValue();
			if (rpm >= me.start_threshold)
			{
				var time_delta = getprop("sim/time/delta-realtime-sec");
				rpm += time_delta * me.spool_time;
				me.rpm.setValue(rpm);
				if (rpm >= me.n1.getValue())
				{
					me.running.setBoolValue(1);
					me.starter.setBoolValue(0);
					me.started = 1;
				}
				else
				{
					me.running.setBoolValue(0);
				}
			}
		}
		elsif (me.running.getBoolValue())
		{
			me.throttle_lever.setValue(me.idle_throttle + (1 - me.idle_throttle) * me.throttle.getValue());
			me.rpm.setValue(me.n1.getValue());
		}
	}
};

# Now do it!

#new: func(n, running = 0, idle_throttle = 0.01, max_start_n1 = 5.21, start_threshold = 3, 
#     spool_time = 4, start_time = 0.02, shutdown_time = 4)

      var aapp     = Jet.new(4 , 0 , 0.01 , 10 , 6 , 6 , 0.05 , 3);
      var engine1 = Jet.new(0 , 0 , 0.005 , 12.8 , 10 , 1 , 0.05 , 1);
      var engine2 = Jet.new(1 , 0 , 0.005 , 12.2 , 10 , 1 , 0.05 , 1);
	  var engine3 = Jet.new(2 , 0 , 0.005 , 12.7 , 10 , 1 , 0.05 , 1);
	  var engine4 = Jet.new(3 , 0 , 0.005 , 12.6 , 10 , 1 , 0.05 , 1);
	  
	  aapp.init();
	  engine1.init();
	  engine2.init();
	  engine3.init();
	  engine4.init();
