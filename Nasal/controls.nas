var controls = {};

controls.FuelSelector = {
	new: func(i) {
		var obj = {
			parents: [controls.FuelSelector],
			auxiliary_fuel_tanks_node: props.globals.getNode("/sim/equipment/auxiliary-fuel-tanks"),
			fuel_selector_node: props.globals.getNode("/controls/fuel/selector[" ~ i ~ "]"),
		};
		
		return obj;
	},
	adjust: func(dir) {
		fuel_selector = me.fuel_selector_node.getValue() + dir;
		if (!me.auxiliary_fuel_tanks_node.getBoolValue() and fuel_selector == 2) {
			fuel_selector += dir;
		}
		me.fuel_selector_node.setIntValue(math.clamp(fuel_selector, 0, 3));
	},
};

controls.Magnetos = {
	new: func(i) {
		var obj = {
			parents: [controls.Magnetos],
			left_mag_node: props.globals.getNode("/controls/engines/engine[" ~ i ~ "]/left-magneto"),
			right_mag_node: props.globals.getNode("/controls/engines/engine[" ~ i ~ "]/right-magneto"),
			magnetos_node: props.globals.getNode("/controls/engines/engine[" ~ i ~ "]/magnetos"),
			flag: 0
		};
		
		obj.left_mag_listener = setlistener(obj.left_mag_node, func(node) obj.update(node));
		obj.right_mag_listener = setlistener(obj.right_mag_node, func(node) obj.update(node));
		obj.magnetos_listener = setlistener(obj.left_mag_node, func(node) obj.update(node));
	},
	update: func(node) {
		me.flag and return;
		me.flag = 1;
		
		if (node.getPath() == me.magnetos_node.getPath()) {
			var value = node.getValue();
			var r = math.floor(value / 2);
			var l = value - r * 2;
			me.left_mag_node.setBoolValue(l);
			me.right_mag_node.setBoolValue(r);
		} else {
			var left_mag = me.left_mag_node.getBoolValue();
			var right_mag = me.right_mag_node.getBoolValue();
			me.magnetos_node.setIntValue(left_mag + right_mag * 2);
		}
		me.flag = 0;
	}
};

controls.fuel_selector = [controls.FuelSelector.new(0), controls.FuelSelector.new(1)];
controls.magneto = [controls.Magnetos.new(0), controls.Magnetos.new(1)];

