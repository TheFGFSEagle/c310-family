failures = {};

failures.BaseFailure = {
	GuiFuncCommand: {
		Trigger: 0,
		Repair: 1,
	},
	GuiFuncImplFactory: {
		Button: func(button, command) {
			if (command == failures.BaseFailure.GuiFuncCommand.Trigger) {
				button.setChecked(1);
			} else {
				button.setChecked(0)
			}
		}
	},
	new: func(name) {
		var obj = {
			parents: [failures.BaseFailure],
			name: name,
		};
		return obj;
	},
};

failures.Failure = {
	new: func(name, failedNode = nil, guiFunc = nil) {
		var obj = failures.BaseFailure.new();
		obj.parents = [failures.Failure] ~ obj.parents;
		obj.failedNode = failedNode;
		obj._timer = maketimer(0, func {
			obj.trigger();
		});
		obj._timer.simulatedTime = 1;
		obj._timer.singleShot = 1;
		
		if (isstr(obj.failedNode)) {
			obj.failedNode = props.globals.getNode(obj.failedNode, 1);
		}
		
		if (!isa(obj.failedNode, props.Node)) {
			obj.failedNode = props.Node.new();
		}
		
		me.setGuiFunc(guiFunc);
		
		return obj;
	},
	
	trigger: func() {
		me.failedNode.setBoolValue(1);
		me.guiFunc(failures.BaseFailure.GuiFuncCommand.Trigger);
	},
	
	repair: func() {
		me.failedNode.setBoolValue(0);
		me._timer.stop();
		me.guiFunc(failures.BaseFailure.GuiFuncCommand.Trigger);
	},
	
	setFailed: func(failed) {
		if (failed) {
			me.trigger();
		} else {
			me.repair();
		}
	},
	
	triggerAfter: func(sec) {
		me._timer.restart(sec);
	},
	
	setGuiFunc: func(guiFunc) {
		me.guiFunc = isfunc(guiFunc) ? guiFunc : func {};
	},
};

failures.IndexedFailure = {
	new: func(name, failedPropTemplate, indexRange, guiFuncs = nil) {
		var obj = failures.BaseFailure.new(name);
		obj.parents = [failures.IndexedFailure] ~ obj.parents;
		obj.failedPropTemplate = failedPropTemplate;
		obj._currentIndex = -1;
		obj._minIndex = indexRange[0];
		obj._maxIndex = indexRange[1];
		obj._timer = maketimer(0, func {
			if (obj._currentIndex > -1) {
				obj.trigger(obj._currentIndex);
			}
		});
		obj._timer.simulatedTime = 1;
		obj._timer.singleShot = 1;
		
		obj.setGuiFuncs(guiFuncs);
		
		return obj;
	},
	
	checkIndex: func(index) {
		if (!(index >= me._minIndex and index <= me._maxIndex)) {
			die("failures.IndexedFailure: index " ~ index ~ " not in allowed range [" ~ me._minIndex ~ ", " ~ me._maxIndex ~ "] !");
		}
	},
	
	getNode: func(index) {
		if (isstr(me.failedPropTemplate)) {
			return props.globals.getNode(string.replace(me.failedPropTemplate, "#", index), 1);
		} else {
			return props.Node.new();
		}
	},
	
	trigger: func(index) {
		me.checkIndex(index);
		me.getNode(index).setBoolValue(1);
		me.guiFuncs[index](failures.BaseFailure.GuiFuncCommand.Trigger);
	},
	
	repair: func(index) {
		me.checkIndex(index);
		me.getNode(index).setBoolValue(0);
		me.guiFuncs[index](failures.BaseFailure.GuiFuncCommand.Repair);
	},
	
	setFailed: func(index, failed) {
		if (failed) {
			me.trigger(index);
		} else {
			me.repair(index);
		}
	},
	
	triggerAfter: func(sec, index) {
		me.checkIndex(index);
		me._currentIndex = index;
		me._timer.restart(sec);
	},
	
	setGuiFuncs: func(guiFuncs...) {
		if (isvec(guiFuncs[0])) {
			guiFuncs = guiFuncs[0];
		}
		while (size(guiFuncs) < me._maxIndex - me._minIndex + 1) {
			append(guiFuncs, func {});
		}
		for (var i = 0; i < size(guiFuncs); i += 1) {
			if (!isfunc(guiFuncs[i])) {
				guiFuncs[i] = func {};
			}
		}
		me.guiFuncs = guiFuncs;
	},
	
	setGuiFunc: func(index, guiFunc) {
		me.guiFuncs[index] = isfunc(guiFunc) ? guiFunc : func {};
	}
};

failures.OilSystemLeak = {
	new: func() {
		var obj = failures.IndexedFailure.new("oil system leak", "/engines/engine[#]/oil/system/leak-flow-rate-lbs_s", [0, 1]);
		obj.parents = [failures.OilSystemLeak] ~ obj.parents;
		
		return obj;
	},
	
	trigger: func(index) {
		me.checkIndex(index);
		srand();
		me.getNode(index).setDoubleValue(rand() * 0.5);
		me.guiFuncs[index](failures.BaseFailure.GuiFuncCommand.Trigger);
	},
	
	repair: func(index) {
		me.checkIndex(index);
		me.getNode(index).setDoubleValue(0);
		me.guiFuncs[index](failures.BaseFailure.GuiFuncCommand.Repair);
	},
};
failures.OilReservoirLeak = {
	new: func() {
		var obj = failures.IndexedFailure.new("oil reservoir leak", "/engines/engine[#]/oil/reservoir/leak-flow-rate-lbs_s", [0, 1]);
		obj.parents = [failures.OilReservoirLeak] ~ obj.parents;
		
		return obj;
	},
	
	trigger: func(index) {
		me.checkIndex(index);
		srand();
		me.getNode(index).setDoubleValue(rand() * 0.5);
		me.guiFuncs[index](failures.BaseFailure.GuiFuncCommand.Trigger);
	},
	
	repair: func(index) {
		me.checkIndex(index);
		me.getNode(index).setDoubleValue(0);
		me.guiFuncs[index](failures.BaseFailure.GuiFuncCommand.Repair);
	},
};

failures.oilSystemLeak = failures.OilSystemLeak.new();
failures.oilReservoirLeak = failures.OilReservoirLeak.new();

failures.Dialog = {
	new: func {
		var obj = canvas.Window.new(size: [300, 150], type: "dialog", destroy_on_close: 0).setTitle("Failures");
		obj.parents = [failures.Dialog] ~ obj.parents;
		
		obj.canvas = obj.getCanvas(create: 1).set("background", canvas.style.getColor("bg_color"));
		obj.root = obj.canvas.createGroup();
		obj.layout = canvas.VBoxLayout.new();
		obj.canvas.setLayout(obj.layout);
		obj.tabs = canvas.gui.widgets.TabWidget.new(obj.root, canvas.style, {});
		obj.tabsContent = obj.tabs.getContent();
		obj.layout.addItem(obj.tabs);
		
		obj.enginesTab = canvas.GridLayout.new();
		obj.tabs.addTab("general", "Engines", obj.enginesTab);
		
		obj.oilSystemLeakLabel = canvas.gui.widgets.Label.new(obj.tabsContent, canvas.style, {})
						.setText("Oil system leak:");
		obj.enginesTab.addItem(obj.oilSystemLeakLabel, 0, 0);
		obj.oilSystemLeakButtonLeft = canvas.gui.widgets.Button.new(obj.tabsContent, canvas.style, {})
						.listen("toggled", func(e) {
							c310.failures.oilSystemLeak.setFailed(0, e.detail.checked);
						})
						.setCheckable(1)
						.setText("Left");
		obj.enginesTab.addItem(obj.oilSystemLeakButtonLeft, 1, 0);
		obj.oilSystemLeakButtonRight = canvas.gui.widgets.Button.new(obj.tabsContent, canvas.style, {})
						.listen("toggled", func(e) {
							c310.failures.oilSystemLeak.setFailed(1, e.detail.checked);
						})
						.setCheckable(1)
						.setText("Right");
		obj.enginesTab.addItem(obj.oilSystemLeakButtonRight, 2, 0);
		
		obj.oilReservoirLeakLabel = canvas.gui.widgets.Label.new(obj.tabsContent, canvas.style, {})
						.setText("Oil reservoir leak:");
		obj.enginesTab.addItem(obj.oilReservoirLeakLabel, 0, 1);
		obj.oilReservoirLeakButtonLeft = canvas.gui.widgets.Button.new(obj.tabsContent, canvas.style, {})
						.listen("toggled", func(e) {
							c310.failures.oilReservoirLeak.setFailed(0, e.detail.checked);
						})
						.setCheckable(1)
						.setText("Left");
		obj.enginesTab.addItem(obj.oilReservoirLeakButtonLeft, 1, 1);
		obj.oilReservoirLeakButtonRight = canvas.gui.widgets.Button.new(obj.tabsContent, canvas.style, {})
						.listen("toggled", func(e) {
							c310.failures.oilReservoirLeak.setFailed(1, e.detail.checked);
						})
						.setCheckable(1)
						.setText("Right");
		obj.enginesTab.addItem(obj.oilReservoirLeakButtonRight, 2, 1);
		
		return obj;
	},
	
	del: func {
		foreach (var tab; me.tabs.getTabs()) {
			var widget = tab.takeAt(0);
			while (widget) {
				widget.del();
				widget = tab.takeAt(0);
			}
		}
		failures.dialog = nil;
	}
};
failures.dialog = failures.Dialog.new();

