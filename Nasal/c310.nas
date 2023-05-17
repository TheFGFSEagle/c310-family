var disengage_starters_timer = maketimer(5, func {
	props.globals.setBoolValue("/controls/engines/engine[0]/starter", 0);
	props.globals.setBoolValue("/controls/engines/engine[1]/starter", 0);
});
var disengage_starters_timer.singleShot = 1;
var disengage_starters_timer.simulatedTime = 1;


var autostart_engine = func(i) {
	if (!props.globals.getNode("/engines/engine[" ~ i ~ "]/running").getBoolValue()) {
		props.globals.setIntValue("/controls/fuel/selector[" ~ i ~ "]", 1);
		props.globals.setIntValue("/controls/engines/engine[" ~ i ~ "]/magnetos", 3);
		props.globals.setDoubleValue("/controls/engines/engine[" ~ i ~ "]/throttle", 0);
		props.globals.setDoubleValue("/controls/engines/engine[" ~ i ~ "]/propeller-pitch", 1);
		props.globals.setDoubleValue("/controls/engines/engine[" ~ i ~ "]/mixture", 1);
		props.globals.setBoolValue("/controls/engines/engine[" ~ i ~ "]/starter", 1);
	}
};

var autostop_engine = func(i) {
	if (props.globals.getNode("/engines/engine[" ~ i ~ "]/running")) {
		props.globals.setIntValue("/controls/fuel/selector[" ~ i ~ "]", 0);
		props.globals.setIntValue("/controls/engines/engine[" ~ i ~ "]/magnetos", 0);
		props.globals.setDoubleValue("/controls/engines/engine[" ~ i ~ "]/throttle", 0);
		props.globals.setDoubleValue("/controls/engines/engine[" ~ i ~ "]/propeller-pitch", 1);
		props.globals.setDoubleValue("/controls/engines/engine[" ~ i ~ "]/mixture", 0);
		props.globals.setBoolValue("/controls/engines/engine[" ~ i ~ "]/starter", 0);
	}
};

var autostart = func {
	autostart_engine(0);
	autostart_engine(1);
	disengage_starters_timer.restart(5);
};

var autostop = func {
	autostop_engine(0);
	autostop_engine(1);
	disengage_starters_timer.stop();
};

var autostartstop = func {
	var running = props.globals.getNode("/engines/engine[0]/running").getBoolValue() and props.globals.getNode("/engines/engine[1]/running").getBoolValue();
	if (!running) {
		autostart();
	} else {
		autostop();
	}
};

