var dialogs = {};

dialogs.EquipmentDialog = {
	new: func {
		var obj = {
			parents: [
				dialogs.EquipmentDialog,
				canvas.Window.new(size: [250, 100], type: "dialog", destroy_on_close: 0)
								.setTitle("Equipment options")
								.setBool("resize", 1)
			],
			equipmentNode: props.globals.getNode("sim/equipment"),
		};
		obj.auxiliaryFuelTanksNode = obj.equipmentNode.getNode("auxiliary-fuel-tanks");
		obj.rightLandingLightNode = obj.equipmentNode.getNode("right-landing-light");
		obj.rotatingBeaconNode = obj.equipmentNode.getNode("rotating-beacon");
		obj.canvas = obj.getCanvas(create: 1).set("background", canvas.style.getColor("bg_color"));
		obj.root = obj.canvas.createGroup();
		obj.layout = canvas.VBoxLayout.new();
		obj.canvas.setLayout(obj.layout);
		
		obj.auxiliaryFuelTanksCheckbox = canvas.gui.widgets.PropertyCheckBox.new(
			obj.root, canvas.style, {"node": obj.auxiliaryFuelTanksNode, "label-position": "left"}
		)
						.setText("Auxiliary fuel tanks:");
		obj.layout.addItem(obj.auxiliaryFuelTanksCheckbox);
		
		obj.rightLandingLightCheckbox = canvas.gui.widgets.PropertyCheckBox.new(
			obj.root, canvas.style, {"node": obj.rightLandingLightNode, "label-position": "left"}
		)
						.setText("Right landing light:");
		obj.layout.addItem(obj.rightLandingLightCheckbox);
		
		obj.rotatingBeaconCheckbox = canvas.gui.widgets.PropertyCheckBox.new(
			obj.root, canvas.style, {"node": obj.rotatingBeaconNode, "label-position": "left"}
		)
						.setText("Rotating beacon:");
		obj.layout.addItem(obj.rotatingBeaconCheckbox);
		return obj;
	},
	
	del: func {
		var widget = me.layout.takeAt(0);
		while (widget) {
			widget.del();
			widget = me.layout.takeAt(0);
		}
		equipment_dialog = nil;
	}
};

dialogs.SettingsDialog = {
	new: func {
		var obj = {
			parents: [
				dialogs.SettingsDialog,
				canvas.Window.new(size: [250, 150], type: "dialog", destroy_on_close: 0).setTitle("Settings")
			],
			realisticFDMNode: props.globals.getNode("/sim/realism/realistic-fdm"),
			fogNode: props.globals.getNode("/sim/model/effects/interior/windows/fog-enabled"),
			frostNode: props.globals.getNode("/sim/model/effects/interior/windows/frost-enabled"),
			rainNode: props.globals.getNode("/sim/model/effects/interior/windows/rain-enabled"),
			reflectionsNode: props.globals.getNode("/sim/model/effects/interior/windows/reflections-enabled"),
		};
		
		obj.canvas = obj.getCanvas(create: 1).set("background", canvas.style.getColor("bg_color"));
		obj.root = obj.canvas.createGroup();
		obj.layout = canvas.VBoxLayout.new();
		obj.canvas.setLayout(obj.layout);
		obj.tabs = canvas.gui.widgets.TabWidget.new(obj.root, canvas.style, {});
		obj.layout.addItem(obj.tabs);
		
		obj.generalTab = canvas.VBoxLayout.new();
		obj.tabs.addTab("general", "General", obj.generalTab);
		
		obj.realisticFDMCheckbox = canvas.gui.widgets.PropertyCheckBox.new(
			obj.root, canvas.style, {"label-position": "left", "node": obj.realisticFDMNode}
		)
						.setText("Realistic FDM:");
		obj.generalTab.addItem(obj.realisticFDMCheckbox);
		
		obj.effectsTab = canvas.VBoxLayout.new();
		obj.tabs.addTab("effects", "Effects", obj.effectsTab);
		
		obj.fogCheckbox = canvas.gui.widgets.PropertyCheckBox.new(
			obj.root, canvas.style, {"label-position": "left", "node": obj.fogNode}
		)
											.setText("Fog:");
		obj.effectsTab.addItem(obj.fogCheckbox);
		
		obj.frostCheckbox = canvas.gui.widgets.PropertyCheckBox.new(
			obj.root, canvas.style, {"label-position": "left", "node": obj.frostNode}
		)
											.setText("Frost:");
		obj.effectsTab.addItem(obj.frostCheckbox);
		
		obj.rainCheckbox = canvas.gui.widgets.PropertyCheckBox.new(
			obj.root, canvas.style, {"label-position": "left", "node": obj.rainNode}
		)
											.setText("Rain:");
		obj.effectsTab.addItem(obj.rainCheckbox);
		
		obj.reflectionsCheckbox = canvas.gui.widgets.PropertyCheckBox.new(
			obj.root, canvas.style, {"label-position": "left", "node": obj.reflectionsNode}
		)
											.setText("Reflections:");
		obj.effectsTab.addItem(obj.reflectionsCheckbox);
		
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
		dialogs.settings_dialog = nil;
	}
};

dialogs.equipment_dialog = dialogs.EquipmentDialog.new();
dialogs.settings_dialog = dialogs.SettingsDialog.new();

