var applyState = func {
	var state = props.globals.getValue("/sim/aircraft-state");
	# c310.failureManager.resetAll();
	if (state == "parked") {
	} else if (state == "take-off") {
		c310.autostart();
	} else if (state == "cruise") {
		c310.autostart();
		props.globals.setDoubleValue("/controls/engines/engine[0]/throttle", 1);
		props.globals.setDoubleValue("/controls/engines/engine[0]/throttle", 1);
	} else if (state == "approach") {
		c310.autostart();
		props.globals.setDoubleValue("/controls/engines/engine[0]/throttle", 0.5);
		props.globals.setDoubleValue("/controls/engines/engine[1]/throttle", 0.5);
	}
};

var unpauseListener = nil;

var checkPausedApplyState = func {
	if (unpauseListener != nil) {
		removelistener(unpauseListener);
		unpauseListener = nil;
	} else {
		if (getprop("/sim/freeze/clock")) {
			unpauseListener = setlistener("/sim/freeze/clock", applyState);
			return;
		}
	}
	applyState();
};

if (!getprop("/sim/presets/onground") and !getprop("/sim/presets/airspeed-kt")) {
	setprop("/sim/presets/airspeed-kt", 100);
}

setlistener("/sim/signals/fdm-initialized", applyState);

