parts = {};
parts.node = props.globals.getNode("/parts", 1);

parts.copyOverlay = func(src, dest, attr = 0) {
	var sp = src.getPath() or "";
	var dp = dest.getPath() or "";

	# sp and dp may be equal but on different trees! 
	# check if dest is sub node of source
	sp = split("/", sp);
	dp = split("/", dp);
	while (size(sp) and size(dp) and (sp[0] == dp[0])) {
		sp = subvec(sp, 1);
		dp = subvec(dp, 1);
	}
    
	foreach(var c; src.getChildren()) {
		var name = c.getName();
		var i = c.getIndex();
		if (i) {
			name ~= "["~i~"]";
		}
		if (!(!size(sp) and size(dp) and name == dp[0])) {
			parts.copyOverlay(src.getNode(name), dest.getNode(name, 1), attr);
		} else {
			logprint(DEV_WARN, "props.copy() skipping "~name~" (recursion!)");
		}
	}
	var type = src.getType();
	var val = src.getValue();
	# don't overwrite existing values
	if (src.getAttribute("archive") and dest.getValue() != nil) {
		return;
	}
	if (type == "ALIAS" or type == "NONE") {
		return;
	} elsif(type == "BOOL") {
		dest.setBoolValue(val);
	} elsif(type == "INT" or type == "LONG") {
		dest.setIntValue(val);
	} elsif(type == "FLOAT" or type == "DOUBLE") {
		dest.setDoubleValue(val);
	} else {
		dest.setValue(val);
	}
	if (attr) {
		dest.setAttribute(src.getAttribute());
	}
}

parts.exec_nasal = func(s, file) {
	var code = call(func {
		compile(s, file);
	}, nil, nil, var compilation_errors = []);

	if (size(compilation_errors)) {
		logprint(LOG_ALERT, "Error(s) compiling code in: " ~ file);
		debug.printerror(compilation_errors);
		return 0;
	}
	if (!code) {
		return; # got an empty string as code; just do nothing
	}
	call(code, [], nil, {}, var runtime_errors = []);

	if(size(runtime_errors)){
		logprint(LOG_ALERT, "Error(s) executing code from: " ~ file);
		debug.printerror(runtime_errors);
		return 0;
	};
	return 1;
}

parts.Part = {
	new: func(category, id, name, pns, user_selectable = 0, optional = 0) {
		if (typeof(pns) == "scalar") {
			pns = [pns];
		}
		var obj = {
			parents: [parts.Part],
			category: category,
			id: id,
			name: name,
			pns: pns,
			user_selectable: user_selectable,
			optional: optional,
			node: parts.node.getNode(id, 1),
			selectedNode: parts.node.initNode("selected-" ~ id, pns[0], "STRING"),
			_cfg: nil,
			_pn: "",
		};
		aircraft.data.add(obj.selectedNode);
		obj.selectedListener = setlistener(obj.selectedNode, func(n) {
			obj.install(n.getValue());
		}, 0, 0);
		obj.node.setValue("name", name);
		for (var i = 0; i < size(pns); i += 1) {
			obj.node.setValue("part-number[" ~ i ~ "]", pns[i]);
		}
		
		return obj;
	},
	
	install: func(pn) {
		if (pn == me._pn) {
			return;
		}
		me.uninstall();
		me._install(pn);
	},
	
	_install: func(pn) {
		if (!pn) {
			return;
		}
		if (!contains(me.pns, pn)) {
			die("Could not install part: No " ~ me.name ~ " with part number " ~ pn ~ " !");
		}
		var part_file = "Parts/" ~ me.id ~ "-" ~ pn ~ ".xml";
		var cfg = io.read_properties(part_file, me.node.getNode("current", 1));
		if (!cfg) {
			logprint(LOG_ALERT, "Failed loading part file '" ~ part_file ~ "' !");
			return;
		}
		me._cfg = cfg;
		me.node.setValue("current/file", part_file);
		props.copy(cfg.getNode("overlay", 1), props.globals);
		parts.copyOverlay(cfg.getNode("persistent-overlay", 1), props.globals);
		
		var load = cfg.getNode("nasal/load", 1).getValue();
		parts.exec_nasal(load, part_file ~ ":/nasal/load");
		me.selectedNode.setValue(pn);
		me._pn = pn;
	},
	
	uninstall: func {
		if (!me._pn) {
			return
		}
		if (!me._cfg) {
			logprint(DEV_WARN, "Trying to uninstall not currently installed part '" ~ me.name ~ "' !");
			return;
		}
		var unload = me._cfg.getNode("nasal/unload", 1).getValue();
		parts.exec_nasal(unload, me.node.getValue("current/file") ~ ":/nasal/unload");
		me.selectedNode.setValue("");
		me._pn = "";
		me.node.getNode("current", 1).removeChildren();
		me._cfg = nil;
	},
	
	del: func {
		aircraft.data.remove(me.selectedNode);
	},
};

parts.Manager = {
	new: func() {
		var obj = {
			parents: [parts.Manager],
			node: parts.node,
			parts: {},
			categories: {},
			current_category: "",
		};
		
		return obj;
	},
	createCategory: func(id, name) {
		me.current_category = id;
		me.categories[id] = name;
		return me;
	},
	createPart: func(id, name, pns, user_selectable = 0, optional = 0) {
		if (typeof(pns) == "scalar") {
			pns = [pns];
		}
		if (!size(pns)) {
			die("Could not create part: no part numbers given !");
		}
		var part = parts.Part.new(me.current_category, id, name, pns, user_selectable, optional);
		var selected_pn = part.selectedNode.getValue();
		part.install(contains(part.pns, selected_pn) ? selected_pn : pns[0]);
		me.parts[id] = part;
		
		return me;
	},
	removePart: func(id) {
		if (!contains(me.parts, id)) {
			die("Could not remove part: No part with ID " ~ id ~ " !");
		}
		me.parts[id].uninstall();
		me.parts[id].del();
		delete(me.parts, id);
	},
	
	install: func(id, pn) {
		if (!contains(me.parts, id)) {
			die("Could not install part: No part with ID " ~ id ~ " !");
		}
		me.parts[id].uninstall();
		if (pn) {
			me.parts[id].install(pn);
		}
		return me;
	},
	
	getPart: func(id) {
		if (!contains(me.parts, id)) {
			die("Could not retrieve part: No part with ID " ~ id ~ " !");
		}
		return me.parts[id];
	},
};

parts.Dialog = {
	norebuild: 0,
	new: func {
		var obj = canvas.Window.new(size: [250, 150], type: "dialog", destroy_on_close: 0).setTitle("Parts");
		obj.parents = [parts.Dialog] ~ obj.parents;
		
		obj.canvas = obj.getCanvas(create: 1).set("background", canvas.style.getColor("bg_color"));
		obj.root = obj.canvas.createGroup();
		obj.layout = canvas.VBoxLayout.new();
		obj.canvas.setLayout(obj.layout);
		
		obj.tabs = canvas.gui.widgets.TabWidget.new(obj.root, canvas.style, {});
		obj.tabsContent = obj.tabs.getContent();
		obj.layout.addItem(obj.tabs);
		
		obj.rebuild();
		
		return obj;
	},
	
	rebuild: func() {
		foreach (var tab; values(me.tabs.getTabs())) {
			var widget = tab.takeAt(0);
			while (widget != nil) {
				if (ishash(widget) and widget["del"] != nil) {
					widget.del();
				}
				widget = tab.takeAt(0);
			}
		}
		foreach (var tabid; keys(me.tabs._tabs)) {
			me.tabs.removeTab(tabid);
		}
		foreach (var catid; keys(parts.manager.categories)) {
			me[catid ~ "Tab"] = canvas.VBoxLayout.new();
			me.tabs.addTab(catid, parts.manager.categories[catid], me[catid ~ "Tab"]);
			foreach(var part; values(parts.manager.parts)) {
				if (!part.user_selectable) {
					continue;
				}
				if (part.category == catid) {
					me.createPartWidget(me[catid ~ "Tab"], part);
				}
			}
			if (me[catid ~ "Tab"].count() == 0) {
				me.tabs.removeTab(catid);
			}
		}
	},
	
	createPartWidget: func(tab, part) {
		var partLayout = canvas.HBoxLayout.new();
		tab.addItem(partLayout);
		var partLabel = canvas.gui.widgets.Label.new(me.tabsContent, canvas.style, {})
						.setText(part.name);
		partLayout.addItem(partLabel);
		var partSelector = canvas.gui.widgets.PropertyComboBox.new(me.tabsContent, canvas.style, {"node": part.selectedNode});
		partSelector.setPropertySynced(0);
		partLayout.addItem(partSelector);
		if (part.optional) {
			partSelector.addMenuItem("", "");
		}
		foreach (var pn; part.pns) {
			partSelector.addMenuItem(pn, pn);
		}
		partSelector.setPropertySynced(1);
		partSelector.setCurrentByValue(part.selectedNode.getValue());
	},
	
	show: func {
		me.rebuild();
		call(me.parents[1].show, [], me);
	},
	
	del: func {
		foreach (var tab; me.tabs.getTabs()) {
			var widget = tab.takeAt(0);
			while (widget) {
				widget.del();
				widget = tab.takeAt(0);
			}
		}
		parts.dialog = nil;
	}
};

parts.manager = parts.Manager.new();
parts.dialog = parts.Dialog.new();

