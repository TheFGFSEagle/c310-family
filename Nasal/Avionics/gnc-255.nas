var _instances = [nil, nil, nil];

var GNC255 = {
	new: func(instanceIndex, instrumentationNode) {
		var obj = {
			parents: [GNC255],
			instanceIndex: instanceIndex,
			_canvas: canvas.new({"size": [664, 128], "view": [664, 128]}),
			rootNode: instrumentationNode.getNode("gnc-255[" ~ instanceIndex ~ "]", 1),
			commNode: instrumentationNode.getNode("comm[" ~ instanceIndex ~ "]", 1),
			navNode: instrumentationNode.getNode("nav[" ~ instanceIndex ~ "]", 1),
			_oldOuterTuneKnobValue: 0,
			_oldInnerTuneKnobValue: 0,
		};
		
		obj.voltsNode = props.globals.getNode("/systems/electrical/consumers/comm[" ~ instanceIndex ~ "]/volts", 1);
		obj.ratedVoltsNode = props.globals.getNode("/systems/electrical/consumers/comm[" ~ instanceIndex ~ "]/rated-volts", 1);
		
		obj.modeNode = obj.rootNode.getNode("mode", 1);
		obj.displayBrightnessNode = obj.rootNode.getNode("display-brightness-norm", 1);
		obj.outerTuneKnobNode = obj.rootNode.getNode("outer-tune-knob-deg", 1);
		obj.innerTuneKnobNode = obj.rootNode.getNode("inner-tune-knob-deg", 1);
		obj.flipFlopButtonNode = obj.rootNode.getNode("flip-flop-button-pressed", 1);
		obj.commNavButtonNode = obj.rootNode.getNode("comm-nav-button-pressed", 1);
		
		obj.poweredNode = obj.commNode.getNode("powered", 1);
		obj.powerBtnNode = obj.commNode.getNode("power-btn", 1);
		obj.commVolumeNode = obj.commNode.getNode("volume", 1);
		obj.commSquelchNode = obj.commNode.getNode("squelch", 1);
		obj.commSelectedFreqNode = obj.commNode.getNode("frequencies/selected-mhz", 1);
		obj.commStandbyFreqNode = obj.commNode.getNode("frequencies/standby-mhz", 1);
		obj.navVolumeNode = obj.navNode.getNode("volume", 1);
		obj.navIdentNode = obj.navNode.getNode("ident", 1);
		obj.navSelectedFreqNode = obj.navNode.getNode("frequencies/selected-mhz", 1);
		obj.navStandbyFreqNode = obj.navNode.getNode("frequencies/standby-mhz", 1);
		
		obj.init();
		
		obj.modeNode.setValue("comm");
		
		return obj;
	},
	
	init: func {
		var fgColor = [0.6, 0.95, 0.95];
		var bgColor = [0, 0.05, 0.3];
		
		me._canvas.addPlacement({"node": "GNC255Display" ~ (me.instanceIndex + 1)});
		me.display = me._canvas.createGroup();
		me.background = me.display.createChild("path", "background")
			.setColorFill(bgColor)
			.moveTo(0, 0)
			.horiz(664)
			.vert(128)
			.horiz(-664)
			.close();
		
		me.selectedFreqText = me.display.createChild("text", "selectedFreq")
						.setTranslation(296, 64)
						.setAlignment("right-bottom")
						.setFont("garmin-11x17.ttf")
						.setFontSize(60)
						.setColor(fgColor)
						.setText("999.999");
		me.standbyFreqText = me.display.createChild("text", "standbyFreq")
						.setTranslation(652, 64)
						.setAlignment("right-bottom")
						.setFont("garmin-11x17.ttf")
						.setFontSize(60)
						.setColor(fgColor)
						.setText("999.999");
		me.activeFreqAnnun = me.display.createChild("text", "activeFreqAnnun")
						.setTranslation(8, 56)
						.setAlignment("left-center")
						.setFont("garmin-3x5.ttf")
						.setFontSize(16)
						.setColor(fgColor)
						.setText("ACT");
		me.standbyFreqAnnun = me.display.createChild("text", "standbyFreqAnnun")
						.setTranslation(364, 56)
						.setAlignment("left-center")
						.setFont("garmin-3x5.ttf")
						.setFontSize(16)
						.setColor(fgColor)
						.setText("STB");
		me.squelchIdentAnnun = me.display.createChild("text", "squelchIdentAnnun")
						.setTranslation(8, 32)
						.setAlignment("left-center")
						.setFont("garmin-5x7.ttf")
						.setFontSize(20)
						.setColor(fgColor)
						.setText("SQ");
		me.commNavAnnun = me.display.createChild("text", "commNavAnnun")
						.setTranslation(308, 24)
						.setAlignment("left-center")
						.setFont("garmin-5x7.ttf")
						.setFontSize(20)
						.setColor(fgColor)
						.setText("COM");
		
		me.voltsListener = setlistener(me.voltsNode, func(n) {
			me.poweredNode.setBoolValue(me.voltsNode.getDoubleValue() > 6);
			me.displayBrightnessNode.setDoubleValue(me.voltsNode.getDoubleValue() / me.ratedVoltsNode.getDoubleValue());
		}, 0, 1);
		me.commVolumeKnobListener = setlistener(me.commVolumeNode, func(n) {
			me.powerBtnNode.setBoolValue(n.getValue() > 0 ? 1 : 0);
		});
		me.poweredListener = setlistener(me.poweredNode, func me.update());
		me.outerTuneKnobListener = setlistener(me.outerTuneKnobNode, func me.tuneKnobMoved());
		me.innerTuneKnobListener = setlistener(me.innerTuneKnobNode, func me.tuneKnobMoved());
		me.flipFlopButtonListener = setlistener(me.flipFlopButtonNode, func(n) {
			if (n.getBoolValue()) {
				me.flipFlopButtonPressed();
			}
		}, 0, 1);
		me.commNavButtonListener = setlistener(me.commNavButtonNode, func (n) {
			if (n.getBoolValue()) {
				me.commNavButtonPressed();
			}
		}, 0, 1);
		
		me.modeListener = setlistener(me.modeNode, func(n) {
			mode = n.getValue();
			if (mode != "comm" and mode != "nav") {
				me.modeNode.setValue("comm");
			}
			me.frequencyChanged();
		}, 0, 1);
		me.commSelectedFreqListener = setlistener(me.commSelectedFreqNode, func(n) {
			me.frequencyChanged();
		}, 0, 1);
		me.commStandbyFreqListener = setlistener(me.commStandbyFreqNode, func(n) {
			me.frequencyChanged();
		}, 0, 1);
		me.navSelectedFreqListener = setlistener(me.navSelectedFreqNode, func(n) {
			me.frequencyChanged();
		}, 0, 1);
		me.navStandbyFreqListener = setlistener(me.navStandbyFreqNode, func(n) {
			me.frequencyChanged();
		}, 0, 1);
	},
	
	del: func {
		removelistener(me.voltsListener);
		removelistener(me.poweredListener);
		removelistener(me.outerTuneKnobListener);
		removelistener(me.innerTuneKnobListener);
		removelistener(me.flipFlopButtonListener);
		removelistener(me.commNavButtonListener);
		removelistener(me.modeListener);
		removelistener(me.commSelectedFreqListener);
		removelistener(me.commStandbyFreqListener);
		removelistener(me.navSelectedFreqListener);
		removelistener(me.navStandbyFreqListener);
		#me.timer.del();
		#me.annunTimer.stop();
		me._canvas._node.removeChildren("placement");
		me._canvas.del();
	},
	
	update: func {
		if (me.poweredNode.getBoolValue()) {
			me.display.show();
		} else {
			me.display.hide();
		}
		
		# TODO: remove when squelch / NAV ident are implemented
		me.squelchIdentAnnun.hide();
	},
	
	frequencyChanged: func {
		var selectedFreqNode = nil;
		var standbyFreqNode = nil;
		if (me.modeNode.getValue() == "comm") {
			me.commNavAnnun.setText("COM");
			selectedFreqNode = me.commSelectedFreqNode;
			standbyFreqNode = me.commStandbyFreqNode;
		} else {
			me.commNavAnnun.setText("NAV");
			selectedFreqNode = me.navSelectedFreqNode;
			standbyFreqNode = me.navStandbyFreqNode;
		}
		
		me.selectedFreqText.setText(sprintf("%07.3f", selectedFreqNode.getDoubleValue()));
		me.standbyFreqText.setText(sprintf("%07.3f", standbyFreqNode.getDoubleValue()));
	},
	
	tuneKnobMoved: func {
		var newOuterTuneKnobValue = me.outerTuneKnobNode.getDoubleValue();
		var newInnerTuneKnobValue = me.innerTuneKnobNode.getDoubleValue();
		var outerDirection = math.sign(newOuterTuneKnobValue - me._oldOuterTuneKnobValue);
		var innerDirection = math.sign(newInnerTuneKnobValue - me._oldInnerTuneKnobValue);
		if (outerDirection == 0 and innerDirection == 0) {
			return;
		}
		var freqNode = nil;
		if (me.modeNode.getValue() == "comm") {
			freqNode = me.commStandbyFreqNode;
		} else {
			freqNode = me.navStandbyFreqNode;
		}
		var freq = freqNode.getDoubleValue();
		var mhz = math.floor(freq);
		var khz = freq - mhz;
		mhz += outerDirection;
		khz += innerDirection * 0.025;
		freqNode.setDoubleValue(mhz + khz);
		me._oldOuterTuneKnobValue = newOuterTuneKnobValue;
		me._oldInnerTuneKnobValue = newInnerTuneKnobValue;
	},
	
	flipFlopButtonPressed: func {
		var selectedFreqNode = nil;
		var standbyFreqNode = nil;
		if (me.modeNode.getValue() == "comm") {
			selectedFreqNode = me.commSelectedFreqNode;
			standbyFreqNode = me.commStandbyFreqNode;
		} else {
			selectedFreqNode = me.navSelectedFreqNode;
			standbyFreqNode = me.navStandbyFreqNode;
		}
		
		props.swapValues(selectedFreqNode, standbyFreqNode);
	},
	
	commNavButtonPressed: func {
		me.modeNode.setValue(me.modeNode.getValue() == "nav" ? "comm" : "nav");
	},
};

var install = func(instanceIndex = 0) {
	if (_instances[instanceIndex] == nil) {
		_instances[instanceIndex] = GNC255.new(instanceIndex, props.globals.getNode("/instrumentation"));
	}
};
var uninstall = func(instanceIndex = 0) {
	if (_instances[instanceIndex] != nil) {
		_instances[instanceIndex].del();
		_instances[instanceIndex] = nil;
	}
};
