parts = {};
parts.items = {};
parts.node = props.globals.getNode("/parts", 1);

var exec_nasal = func(s, file) {
	var code = call(func {
		compile(s, file);
	}, nil, nil, var compilation_errors = []);

	if (size(compilation_errors)) {
		logprint(LOG_ALERT, "Error(s) compiling code in: " ~ file);
		foreach(var e; compilation_errors) {
			logprint(LOG_ALERT, "\t" ~ e);
		}
		return 0;
	}
	
	call(code, [], nil, nil, var runtime_errors = []);

	if(size(runtime_errors)){
		logprint(LOG_ALERT, "Error(s) executing code from: " ~ file);
		foreach(var e; runtime_errors) {
			logprint(LOG_ALERT, "\t" ~ e);
		}
		return 0;
	};
	return 1;
}

parts.Part = {
	new: func(id, name, pns, user_selectable = 0) {
		if (typeof(pns) == "scalar") {
			pns = [pns];
		}
		var obj = {
			parents: [parts.Part],
			id: id,
			name: name,
			pns: pns,
			user_selectable: user_selectable,
			node: parts.node.getNode(id, 1),
		};
		obj.node.setValue("name", name);
		for (var i = 0; i < size(pns); i += 1) {
			obj.node.setValue("part-number[" ~ i ~ "]", pns[i]);
		}
		
		return obj;
	},
	
	install: func(pn) {
		if (!contains(me.pns, pn)) {
			die("Could not install part: No " ~ me.name ~ " with part number " ~ pn ~ " !");
		}
		var part_file = "Parts/" ~ me.id ~ "-" ~ pn ~ ".xml";
		me.node.setValue("current/file", part_file);
		var cfg = io.read_properties(part_file, me.node.getNode("current", 1));
		props.copy(cfg.getNode("overlay"), props.globals);
		
		var load = cfg.getNode("nasal/load", 1).getValue();
		exec_nasal(load, part_file ~ ":/nasal/load");
	},
	
	uninstall: func {
		var unload = cfg.getNode("current/nasal/unload", 1).getValue();
		exec_nasal(unload, me.node.getValue("current/file") ~ ":/nasal/unload");
		me.node.getNode("current", 1).removeChildren();
	}
};

parts.PartsManager = {
	new: func(node) {
		var obj = {
			parents: [parts.PartsManager],
			node: node,
			parts: {},
		};
		
		return obj;
	},
	createPart: func(id, name, pns, user_selectable=0) {
		if (typeof(pns) == "scalar") {
			pns = [pns];
		}
		
		var part = parts.Part.new(id, name, pns, user_selectable);
		part.install(pns[0]);
		me.parts[id] = part;
		
		return me;
	},
	
	install: func(id, pn) {
		if (!contains(me.parts, id)) {
			die("Could not install part: No part with ID " ~ id ~ " !");
		}
		me.parts[id].uninstall();
		me.parts[id].install(pn);
		return me;
	},
	
	getPart: func(id) {
		if (!contains(me.parts, id)) {
			die("Could not retrieve part: No part with ID " ~ id ~ " !");
		}
		return me.parts[id];
	},
};

parts.manager = parts.PartsManager.new(parts.node)
				.createPart("fuel-boost-pump", "Fuel boost pump", ["1C6-10"]);

