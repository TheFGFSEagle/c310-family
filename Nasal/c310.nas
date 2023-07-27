aircraft.data.save(1);

parts.manager.createCategory("instruments", "Instruments")
				.createPart("clock", "Clock", ["AT420100", "35-380004-1"], 1)
				.createPart("rudder-position-indicator", "Rudder position indicator", ["default"], 1, 1)
				.createPart("turn-coordinator", "Turn coordinator", ["23-328-04"])
				.createCategory("misc", "Miscellaneous")
				.createPart("stall-warning", "Stall warning", ["0511062-7"])
				.createCategory("lighting", "Lighting")
				.createPart("uv-instrument-lights", "UV instrument lights", ["AN3125-1"])
				.createPart("red-instrument-light", "Red instrument light", ["AN3124-307"])
				.createPart("dome-lights", "Dome lights", ["AN3124-307"])
				.createCategory("fuel-system", "Fuel system")
				.createPart("fuel-boost-pump", "Fuel boost pump", ["1C6-10"]);


var maxStartingTime = 6;

var disengageLeftStarterTimer = maketimer(maxStartingTime, func {
	print("disengageLeftStarterTimer");
	props.globals.setBoolValue("/controls/engines/engine[0]/starter-button", 0);
	props.globals.setBoolValue("/controls/engines/engine[0]/master-alt", 1);
	startRightEngineTimer.start();
});
disengageLeftStarterTimer.singleShot = 1;
disengageLeftStarterTimer.simulatedTime = 1;
var disengageRightStarterTimer = maketimer(maxStartingTime, func {
	print("disengageRightStarterTimer");
	props.globals.setBoolValue("/controls/engines/engine[1]/starter-button", 0);
	props.globals.setBoolValue("/controls/engines/engine[1]/master-alt", 1);
	autostartElectricsAfterEngineStart();
});
disengageRightStarterTimer.singleShot = 1;
disengageRightStarterTimer.simulatedTime = 1;
var disengageStarterTimers = [disengageLeftStarterTimer, disengageRightStarterTimer];

var startRightEngineTimer = maketimer(3, func {
	print("startRightEngineTimer");
	autostartEngine(1);
});
startRightEngineTimer.singleShot = 1;
startRightEngineTimer.simulatedTime = 1;

var autostartEngine = func(i) {
	if (!props.globals.getNode("/engines/engine[" ~ i ~ "]/running").getBoolValue()) {
		print("autostartEngine(" ~ i ~ ")");
		props.globals.setIntValue("/controls/fuel/selector[" ~ i ~ "]", 1);
		props.globals.setBoolValue("/controls/engines/engine[" ~ i ~ "]/left-magneto", 1);
		props.globals.setBoolValue("/controls/engines/engine[" ~ i ~ "]/right-magneto", 1);
		props.globals.setDoubleValue("/controls/engines/engine[" ~ i ~ "]/throttle", 0);
		props.globals.setDoubleValue("/controls/engines/engine[" ~ i ~ "]/propeller-pitch", 1);
		props.globals.setDoubleValue("/controls/engines/engine[" ~ i ~ "]/mixture", 1);
		props.globals.setBoolValue("/controls/engines/engine[" ~ i ~ "]/starter-button", 1);
		disengageStarterTimers[i].start();
	}
};

var autostopEngine = func(i) {
	if (props.globals.getNode("/engines/engine[" ~ i ~ "]/running").getBoolValue()) {
		props.globals.setIntValue("/controls/fuel/selector[" ~ i ~ "]", 0);
		props.globals.setBoolValue("/controls/engines/engine[" ~ i ~ "]/left-magneto", 0);
		props.globals.setBoolValue("/controls/engines/engine[" ~ i ~ "]/right-magneto", 0);
		props.globals.setDoubleValue("/controls/engines/engine[" ~ i ~ "]/throttle", 0);
		props.globals.setDoubleValue("/controls/engines/engine[" ~ i ~ "]/propeller-pitch", 1);
		props.globals.setDoubleValue("/controls/engines/engine[" ~ i ~ "]/mixture", 0);
		props.globals.setBoolValue("/controls/engines/engine[" ~ i ~ "]/starter-button", 0);
	}
};

var autostartElectricsBeforeEngineStart = func {
	print("autostartElectricsBeforeEngineStart");
	props.globals.setBoolValue("/controls/electric/battery-switch", 1);
	props.globals.setBoolValue("/controls/lighting/beacon", 1);
}

var autostartElectricsAfterEngineStart = func {
	print("autostartElectricsAfterEngineStart");
	props.globals.setBoolValue("/controls/lighting/nav-lights", 1);
	props.globals.setIntValue("/controls/lighting/landing-light[0]", 1);
	props.globals.setIntValue("/controls/lighting/landing-light[1]", 1);
}

var autostopElectrics = func {
	props.globals.setBoolValue("/controls/lighting/nav-lights", 0);
	props.globals.setBoolValue("/controls/lighting/beacon", 0);
	props.globals.setIntValue("/controls/lighting/landing-light[0]", -1);
	props.globals.setIntValue("/controls/lighting/landing-light[1]", -1);
	props.globals.setBoolValue("/controls/engines/engine[0]/master-alt", 0);
	props.globals.setBoolValue("/controls/engines/engine[1]/master-alt", 0);
	props.globals.setBoolValue("/controls/electric/battery-switch", 0);
}

var autostart = func {
	print("autostart");
	autostopElectrics();
	autostartElectricsBeforeEngineStart();
	autostartEngine(0);
};

var autostop = func {
	startRightEngineTimer.stop();
	autostopEngine(0);
	autostopEngine(1);
	autostopElectrics();
};

var autostartstop = func {
	var running = props.globals.getNode("/engines/engine[0]/running").getBoolValue() and props.globals.getNode("/engines/engine[1]/running").getBoolValue();
	if (!running) {
		autostart();
	} else {
		autostop();
	}
};

