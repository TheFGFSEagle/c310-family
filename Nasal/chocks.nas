var Chock = {
	new: func(index) {
		var obj = {
			parents: [Chock],
			_index: index,
			_node: nil,
			_visible: 0,
			_stowedNode: props.globals.getNode("/sim/model/chocks/chocks[" ~ index ~ "]/stowed", 1),
		};
		return obj;
	},
	
	put: func {
		if (!me._node) {
			var xoff =  props.globals.getValue("/gear/gear[" ~ me._index ~ "]/xoffset-m");
			var yoff =  props.globals.getValue("/gear/gear[" ~ me._index ~ "]/yoffset-m");
			var pos = geo.aircraft_position();
			pos.apply_course_distance(props.globals.getValue("/orientation/heading-deg", 0), xoff);
			pos.apply_course_distance(props.globals.getValue("/orientation/heading-deg", 0) + 90, yoff);
			pos.set_alt(geo.elevation(pos.lat, pos.lon));
			me._node = geo.put_model(
				"Aircraft/c310-family/Models/Exterior/chocks/chocks-put-" ~ ["front", "left", "right"][me._index] ~ ".xml",
				pos,
				props.globals.getValue("/orientation/heading-deg", 0)
			);
		}
		me._stowedNode.setBoolValue(0);
	},
	
	stow: func {
		if (me._node) {
			me._node.remove();
		}
		me._stowedNode.setBoolValue(1);
		me._node = nil;
	},
	
	toggle: func {
		if (me._stowedNode.getBoolValue()) {
			me.put();
		} else {
			me.stow();
		}
	}
};

var chocks = [Chock.new(0), Chock.new(1), Chock.new(2)];
