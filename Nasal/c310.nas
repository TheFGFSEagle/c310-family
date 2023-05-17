var autostart_engine = func(i) {
	props.globals.setIntValue("/controls/fuel/selector[" ~ i ~ "]", 1);
	props.globals.setIntValue("/controls/engines/engine[" ~ i ~ "]/magnetos", 3);
	props.globals.setDoubleValue("/controls/engines/engine[" ~ i ~ "]/throttle", 0);
	props.globals.setDoubleValue("/controls/engines/engine[" ~ i ~ "]/propeller-pitch", 1);
	props.globals.setDoubleValue("/controls/engines/engine[" ~ i ~ "]/mixture", 1);
	props.globals.setBoolValue("/controls/engines/engine[" ~ i ~ "]/starter", 1);
};

var autostop_engine = func(i) {
	props.globals.setIntValue("/controls/fuel/selector[" ~ i ~ "]", 0);
	props.globals.setIntValue("/controls/engines/engine[" ~ i ~ "]/magnetos", 0);
	props.globals.setDoubleValue("/controls/engines/engine[" ~ i ~ "]/throttle", 0);
	props.globals.setDoubleValue("/controls/engines/engine[" ~ i ~ "]/propeller-pitch", 1);
	props.globals.setDoubleValue("/controls/engines/engine[" ~ i ~ "]/mixture", 0);
	props.globals.setBoolValue("/controls/engines/engine[" ~ i ~ "]/starter", 0);
};

var autostart = func {
	autostart_engine(0);
	autostart_engine(1);
};

var autostop = func {
	autostop_engine(0);
	autostop_engine(1);
};

var autostartstop = func {
	var running = props.globals.getBoolValue("/engines/engine/running");
	if (!running) {
		autostart();
	} else {
		autostop();
	}
};

