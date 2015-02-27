# fgcom.nas - Defines and creates an instance of an FGComRadio object used for
# controlling multiple instance of fgcom. See below for an overview and
# http://wiki.flightgear.org/index.php/Tuxklok for a detailed guide.
#
# Copyright (C) 2010 Jacob Burbach <jmburbach@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of version 3 of the GNU General Public License as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# OVERVIEW:
#	This script defines and creates an instance of and FGComRadio object. This object is available
#	from nasal as `fgcom.radio', and is used for transmitting, selecting which comm radio(s) to 
#	transmit on, and other minor things.
#
# API:
#	fgcom.radio.ptt(BOOL) - Enable/disable push to talk on the currently selected radio(s). BOOL should be 1 to start transmitting, 0 to stop.
#	fgcom.radio.next_radio() - Switch to the next radio for transmitting. This cycles through comm1, comm2, both(if enabled), and back to comm1.
#	fgcom.radio.select_radio(INT) - Select a specific radio for transmitting. INT should be 0 for comm1, 1 for comm2, or 2 for both(if enabled).
#	fgcom.radio.selected_radio() - Returns the currently selected radio for transmitting. 0 for comm1, 1 for comm2, or 2 for both(if enabled). 
#	fgcom.radio.enable_transmit_both(BOOL) - Enables/disables ability to select both radios for transmitting. BOOL should be 1 to enable, 0 to disable. [1]
#	fgcom.radio.toggle_property_display() - By default fgcom related properties will be displayed on the screen. This toggles visibility on/off. [2]
#
#	(Any other methods or attributes of the FGComRadio object should be considered private and not be used or modified)
#	
#	[1] Transmitting on both radios simultaneously is disabled by default and should only be used for testing purposes.
#	[2] You may change the position and color of the property display by changing the PROPERTY_DISPLAY_* variables below.


# Position and color of the property display, change these if desired. 
var PROPERTY_DISPLAY_POS_X = -160;
var PROPERTY_DISPLAY_POS_Y = -25;
var PROPERTY_DISPLAY_COLOR = [1.0, 1.0, 1.0, 1.0]; #[r, g, b, a]


# A single instance of this class is automatically created and will be available
# from nasal as `fgcom.radio'. Users should never create an instance themselves.
var FGComRadio = {

	new: func()
	{
		var m = { parents: [FGComRadio] };
	
		m.current_radio = 0;
		m.transmit_both_enabled = 0;
		
		m.root_node = props.globals.getNode("/local/fgcom/", 1);

		m.ptt_node = m.root_node.getNode("ptt", 1);
		m.ptt_node.setIntValue(0);
		
		m.active_radio_node = m.root_node.getNode("active_radio", 1);
		m.active_radio_node.setValue("comm1");

		m.comm1_freq_node = m.root_node.getNode("comm1_freq", 1);
		m.comm2_freq_node = m.root_node.getNode("comm2_freq", 1);
		
		# Do it this way so when displayed on the screen they show up
		# in a proper format, ie 120.500 instead of 120.499999991. Cannot
		# just use the `display' class formatting option because we don't
		# all properties to be displayed this way.
		m.comm1_listener = setlistener("/instrumentation/comm[0]/frequencies/selected-mhz",
			func(n) { 
				m.comm1_freq_node.setValue(sprintf("%03.3f", n.getValue()));
			}, 1, 0);
		m.comm2_listener = setlistener("/instrumentation/comm[1]/frequencies/selected-mhz",
			func(n) { 
				m.comm2_freq_node.setValue(sprintf("%03.3f", n.getValue()));
			}, 1, 0);

		m.display = screen.display.new(PROPERTY_DISPLAY_POS_X, PROPERTY_DISPLAY_POS_Y, 1);
		m.display.setcolor(PROPERTY_DISPLAY_COLOR[0], PROPERTY_DISPLAY_COLOR[1],
			 PROPERTY_DISPLAY_COLOR[2], PROPERTY_DISPLAY_COLOR[3]);
		m.display.add(m.ptt_node, m.active_radio_node,
			m.comm1_freq_node,	m.comm2_freq_node);

		return m;
	},

	# Enable/disable talking on currently selected radio(s).
	#
	# param: pushed (bool)
	#	1 to transmit, 0 to stop.
	ptt: func(pushed)
	{
		me.ptt_node.setIntValue(pushed);
		
		if (me.current_radio == 2) {
			setprop("/instrumentation/comm[0]/ptt", pushed);
			setprop("/instrumentation/comm[1]/ptt", pushed);
		}
		else {
			setprop("/instrumentation/comm[" ~ me.current_radio ~ "]/ptt", pushed);
		}
	},

	# Switch to the next radio. Cycles through comm1, comm2, and both (if enabled).
	next_radio: func()
	{
		var next = me.current_radio + 1;
		if (next > 2 or (next == 2 and !me.transmit_both_enabled)) {
			next = 0;
		}

		me.select_radio(next);
	},

	# Select a specific radio for transmitting.
	#
	# param: which (int)
	#	0 for comm1, 1 for comm2, or 2 for both(if enabled).
	select_radio: func(which)
	{
		# check valid
		if (which < 0 or which > 2) {
			return;
		}
		
		# not both unless explicitly enabled
		if (which == 2 and !me.transmit_both_enabled) {
			return;
		}

		# make sure we let go of the mic before switching, or it will get stuck on
		me.ptt(0);

		if (which == 0) {
			me.active_radio_node.setValue("comm1");
		}
		elsif (which == 1) {
			me.active_radio_node.setValue("comm2");
		}
		else {
			me.active_radio_node.setValue("both");
		}

		me.current_radio = which;
	},

	# Returns the currently selected radio. 0 for comm1, 1 for comm2, or 2 for both.
	selected_radio: func()
	{
		return me.current_radio;
	},
	
	# Enable/disable ability to select both radios for transmitting simultaneously.
	#
	# param: enabled (bool)
	#	1 to enable, 0 to disable. (disabled by default)
	enable_transmit_both: func(enabled)
	{
		if (!enabled and me.current_radio == 2) {
			me.select_radio(0);
		}
		me.transmit_both_enabled = enabled;
	},

	# Toggle the property display on and off.
	toggle_property_display: func()
	{
		me.display.toggle();
	}
};

var radio = nil;
_setlistener("/sim/signals/nasal-dir-initialized", 
	func { 
		radio = FGComRadio.new();
	}
);
