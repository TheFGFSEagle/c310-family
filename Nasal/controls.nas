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

controls.fuel_selector = [controls.FuelSelector.new(0), controls.FuelSelector.new(1)];

