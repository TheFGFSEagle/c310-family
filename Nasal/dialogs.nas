var EquipmentDialog = {
	new: func {
		var obj = {
			parents: [
				EquipmentDialog,
				canvas.Window.new(size: [200, 100], type: "dialog", destroy_on_close: 0).setTitle("Equipment options")
			],
			auxiliary_fuel_tanks_node: props.globals.getNode("sim/equipment/auxiliary-fuel-tanks"),
			right_landing_light_node: props.globals.getNode("sim/equipment/right-landing-light"),
		};
		obj.canvas = obj.getCanvas(create: 1).set("background", canvas.style.getColor("bg_color"));
		obj.root = obj.canvas.createGroup();
		obj.layout = canvas.VBoxLayout.new();
		obj.canvas.setLayout(obj.layout);
		
		obj.auxiliary_fuel_tanks_checkbox = canvas.gui.widgets.CheckBox.new(obj.root, canvas.style, {"label-position": "left"})
											.setText("Auxiliary fuel tanks installed:")
											.setChecked(obj.auxiliary_fuel_tanks_node.getBoolValue());
		obj.layout.addItem(obj.auxiliary_fuel_tanks_checkbox);
		obj.auxiliary_fuel_tanks_checkbox.listen("toggled", func (e) {
			obj.auxiliary_fuel_tanks_node.setBoolValue(int(e.detail.checked));
		});
		obj.auxiliary_fuel_tanks_listener = setlistener(obj.auxiliary_fuel_tanks_node, func (n) {
			obj.auxiliary_fuel_tanks_checkbox.setChecked(n.getBoolValue());
		});
		
		obj.right_landing_light_checkbox = canvas.gui.widgets.CheckBox.new(obj.root, canvas.style, {"label-position": "left"})
											.setText("Right landing light installed:")
											.setChecked(obj.right_landing_light_node.getBoolValue());
		obj.layout.addItem(obj.right_landing_light_checkbox);
		obj.right_landing_light_checkbox.listen("toggled", func (e) {
			obj.right_landing_light_node.setBoolValue(int(e.detail.checked));
		});
		obj.right_landing_light_listener = setlistener(obj.right_landing_light_node, func (n) {
			obj.right_landing_light_checkbox.setChecked(n.getBoolValue());
		});
		return obj;
	},
	
	del: func {
		removelistener(me.auxiliary_fuel_tanks_listener);
		removelistener(me.right_landing_light_listener);
		equipment_dialog = nil;
	}
};

equipment_dialog = EquipmentDialog.new();
