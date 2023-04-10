aircraft.data.save(1);

parts.manager.createCategory("instruments", "Instruments")
				.createPart("clock", "Clock", ["AT420100", "35-380004-1"], 1)
				.createCategory("lighting", "Lighting")
				.createPart("uv-instrument-lights", "UV instrument lights", ["AN3125-1"])
				.createPart("red-instrument-light", "Red instrument light", ["AN3124-307"])
				.createPart("dome-lights", "Dome lights", ["AN3124-307"])
				.createCategory("fuel-system", "Fuel system")
				.createPart("fuel-boost-pump", "Fuel boost pump", ["1C6-10"]);


var disengageStartersTimerDelay = 5;
var disengageStartersTimer = maketimer(disengageStartersTimerDelay, func {
	props.globals.setBoolValue("/controls/engines/engine[0]/starter-button", 0);
	props.globals.setBoolValue("/controls/engines/engine[1]/starter-button", 0);
});
disengageStartersTimer.singleShot = 1;
disengageStartersTimer.simulatedTime = 1;


var autostartEngine = func(i) {
	if (!props.globals.getNode("/engines/engine[" ~ i ~ "]/running").getBoolValue()) {
		props.globals.setIntValue("/controls/fuel/selector[" ~ i ~ "]", 1);
		props.globals.setBoolValue("/controls/engines/engine[" ~ i ~ "]/left-magneto", 1);
		props.globals.setBoolValue("/controls/engines/engine[" ~ i ~ "]/right-magneto", 1);
		props.globals.setDoubleValue("/controls/engines/engine[" ~ i ~ "]/throttle", 0);
		props.globals.setDoubleValue("/controls/engines/engine[" ~ i ~ "]/propeller-pitch", 1);
		props.globals.setDoubleValue("/controls/engines/engine[" ~ i ~ "]/mixture", 1);
		props.globals.setBoolValue("/controls/engines/engine[" ~ i ~ "]/starter-button", 1);
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

var autostartElectrics = func {
	props.globals.setBoolValue("/controls/electric/battery-switch", 1);
	props.globals.setBoolValue("/controls/engines/engine[0]/master-alt", 1);
	props.globals.setBoolValue("/controls/engines/engine[1]/master-alt", 1);
	props.globals.setBoolValue("/controls/lighting/nav-lights", 1);
	if (props.globals.getNode("/sim/equipment/rotating-beacon").getBoolValue()) {
		props.globals.setBoolValue("/controls/lighting/beacon", 1);
	}
	props.globals.setIntValue("/controls/lighting/landing-light[0]", 1);
	props.globals.setIntValue("/controls/lighting/landing-light[1]", 1);
}

var autostopElectrics = func {
	props.globals.setBoolValue("/controls/electric/battery-switch", 0);
	props.globals.setBoolValue("/controls/engines/engine[0]/master-alt", 0);
	props.globals.setBoolValue("/controls/engines/engine[1]/master-alt", 0);
	props.globals.setBoolValue("/controls/lighting/nav-lights", 0);
	props.globals.setBoolValue("/controls/lighting/beacon", 0);
	props.globals.setIntValue("/controls/lighting/landing-light[0]", -1);
	props.globals.setIntValue("/controls/lighting/landing-light[1]", -1);
}

var autostart = func {
	autostartEngine(0);
	autostartEngine(1);
	autostartElectrics();
	disengageStartersTimer.restart(disengageStartersTimerDelay);
};

var autostop = func {
	autostopEngine(0);
	autostopEngine(1);
	autostopElectrics();
	disengageStartersTimer.stop();
};

var autostartstop = func {
	var running = props.globals.getNode("/engines/engine[0]/running").getBoolValue() and props.globals.getNode("/engines/engine[1]/running").getBoolValue();
	if (!running) {
		autostart();
	} else {
		autostop();
	}
};

