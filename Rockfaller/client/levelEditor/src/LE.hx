package ;

import Protocol;

import Common;
import elem.*;
import mod.ModAssets;
import mod.*;

/**
 * ...
 * @author Tipyx
 */

enum PaintingMode {
	PMNone;
	PMAdd;
	PMRemove;
}

class LE extends mt.deepnight.HProcess
{
	public static var ME		: LE;

	public var modGrid 			: ModGrid;
	public var modPattern		: ModPattern;
	public var modAssets 		: ModAssets;
	public var modInfo	 		: ModInfos;
	
	var modSet					: mod.ModSet;
	var modFile					: mod.ModFile;
	public var rightMenu		: RightMenu;
	
	public var mouseLeftDown	: Bool;
	
	public var paintingMode		: PaintingMode;
	
	public var actualLevel		: LevelInfo;
	
	public var tweener			: mt.motion.Tweener;
	
	public function new() {
		super();
		
		ME = this;
		
		DataManager.ON_UPDATE_JSON = function () {
			if (actualLevel != null)
				updateUI();
		}
		
		mt.deepnight.hui.Component.BASE_STYLE.bg = mt.deepnight.hui.Style.Bg.Col(0x681A1C, 1);
		mt.deepnight.hui.Button.STYLE.bg = mt.deepnight.hui.Style.Bg.Col(0x29617E, 1);
		
		//actualLevel = DataManager.GET(1);
		
		tweener = new mt.motion.Tweener();
		
		init();
	}
	
	public function init() {
	// Infos
		modInfo = new ModInfos();
		root.addChild(modInfo);
		
	// GRID
		modGrid = new ModGrid(this);
		modGrid.root.x = Std.int(Settings.STAGE_WIDTH * 0.5  - ((Settings.GRID_WIDTH - 0.5) * Settings.SIZE) * 0.5);
		modGrid.root.y = 100;
		root.addChild(modGrid.root);
		
		paintingMode = PaintingMode.PMNone;
		
	// MODULES
		modAssets = new ModAssets(this);
		root.addChild(modAssets.root);
		modAssets.root.y = Std.int(Settings.STAGE_HEIGHT - modAssets.height);
		
		modPattern = new ModPattern();
		modPattern.visible = false;
		modAssets.root.addChild(modPattern);
		
	// RIGHT MENU
		rightMenu = new RightMenu();
		rightMenu.x = Std.int(Settings.STAGE_WIDTH - rightMenu.wid);
		rightMenu.y = 100;
		root.addChild(rightMenu);
		
	// LEFT MENU
		var leftMenu = new mt.deepnight.hui.VGroup(root);
		leftMenu.y = 700;
		
		var btnSave = leftMenu.button("Save", function () {
			save();
		});
	
		var btnFile = leftMenu.button("Options", function () {
			modFile.toggle();
		});
	
		var btnSet = leftMenu.button("Set Levels Params", function () {
			modSet.toggle();
		});
		
		modFile = new mod.ModFile();
		root.addChild(modFile);
		
		modSet = new mod.ModSet();
		root.addChild(modSet);
	
		if (Main.ME.d != null) {
			switch (Main.ME.d) {
				case ProtocolCom.DoTestLE(num) :
					goToLevel(num);
				default :
					goToLevel(1);
			}
		}
		else
			goToLevel(1);
	}
	
	public function goToLevel(numLevel:Int, ?save:Bool = true) {
		if (numLevel >= 1) {
			// SAVE ACTUAL LEVEL
			if (save)
				DataManager.SAVE(LE.ME.actualLevel);
			
			// RESET GRID
			modGrid.reset();
			
			actualLevel = DataManager.GET(numLevel);
			trace(actualLevel);
			
			if (actualLevel.arDeck == null)
				actualLevel.arDeck = [	{v:100 , t:TypeRock.TRClassic("crystal") }, 
										{v:100 , t:TypeRock.TRClassic("ground") },
										{v:100 , t:TypeRock.TRClassic("roc") },
										{v:100 , t:TypeRock.TRClassic("sand") },
										{v:100 , t:TypeRock.TRClassic("vegeta") }
									];
			
			// LOAD GRID
			rightMenu.init(actualLevel);
			modInfo.update();
			modPattern.init(actualLevel);
			
			modGrid.load(actualLevel);
			
			// LOAD GP
			
			paintingMode = PaintingMode.PMNone;
			
			updateUI();			
		}
	}
	
	public function save() {
		if (modInfo != null)
			modInfo.update();
		switch (actualLevel.type) {
			case TypeGoal.TGScoring(v) :
			case TypeGoal.TGCollect(ar) :
			case TypeGoal.TGGelatin(ar) :
			case TypeGoal.TGMercury(num, ar) :
				actualLevel.type = TypeGoal.TGMercury(modInfo.numSquareValid, ar);
		}
		
		modGrid.modGeyser.setGP();
		
		//trace("SAVE : " + actualLevel);
		trace("SAVE : " + actualLevel.arGP);
		DataManager.SAVE(actualLevel);
	}
	
	public function reset() {
		actualLevel.numMoves = 0;
		actualLevel.arGrip = [];
		actualLevel.arGP = [];
		actualLevel.arManualRocks = [];
		actualLevel.arStepScore = [0, 0, 0];
		actualLevel.type = TypeGoal.TGScoring(0);
		
		modGrid.reset();
		modPattern.reset();
		rightMenu.init(actualLevel);
		modGrid.load(actualLevel);
		modInfo.update();
		
		updateUI();
	}
	
	public function updateUI() {
		if (LE.ME.modInfo != null)
			LE.ME.modInfo.update();
			
		modSet.updateBtn("Moves", actualLevel.numMoves > 0);
		
		modSet.updateBtn("Steps Score", true);
			
		for (i in 0...actualLevel.arStepScore.length) {
			if (actualLevel.arStepScore[i] <= 0)
				modSet.updateBtn("Steps Score", false);
				
			if (i > 0
			&&	actualLevel.arStepScore[i] < actualLevel.arStepScore[i - 1])
				modSet.updateBtn("Steps Score", false);
		}
		
		modSet.updateBtn("Goal", true);
		
		switch (actualLevel.type) {
			case TypeGoal.TGScoring(v) :
				if (v <= 0)
					modSet.updateBtn("Goal", false);
			case TypeGoal.TGCollect(ar) :
				if (ar.length == 0)
					modSet.updateBtn("Goal", false);
			case TypeGoal.TGGelatin(ar) :
				if (ar.length == 0)
					modSet.updateBtn("Goal", false);
			case TypeGoal.TGMercury(num, ar) :
				if (num <= 0 || ar.length == 0)
					modSet.updateBtn("Goal", false);
		}
		
		var t = 0;
		for (c in actualLevel.arDeck)
			t += c.v;
			
		modSet.updateBtn("Deck", t == Common.LENGTH_TOTAL_DECK);
	}
	
	override function onEvents(e:hxd.Event) {
		switch(e.kind) {
			case hxd.Event.EventKind.EPush		: onMouseLeftDown();
			case hxd.Event.EventKind.ERelease	: onMouseLeftUp();
			default								:
		}
	}
	
	function onMouseLeftDown() {
		mouseLeftDown = true;
	}
	
	function onMouseLeftUp() {
		mouseLeftDown = false;
		
		paintingMode = PaintingMode.PMNone;
	}
	
	override function update() {
		modGrid.update();
		
		mt.deepnight.hui.Component.updateAll();
		
		tweener.update();
		
		super.update();
	}
}