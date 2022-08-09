package mod;

import Common;

/**
 * ...
 * @author Tipyx
 */
class ModInfos extends h2d.Sprite
{
	var gInfo				: mt.deepnight.hui.HGroup;
	
	var lblText				: mt.deepnight.hui.Label;
	var lblMoves			: mt.deepnight.hui.Label;
	var lblStepScore		: mt.deepnight.hui.Label;
	var lblTypeGoal			: mt.deepnight.hui.Label;
	var lblNumSquareValid	: mt.deepnight.hui.Label;
	
	var le					: LE;
	
	public var hei			: Int;
	
	public var numSquareValid	: Int;

	public function new() {
		super();
		
		le = LE.ME;
		
		numSquareValid = 0;
		
		gInfo = new mt.deepnight.hui.HGroup(this);
		gInfo.setWidth(Settings.STAGE_WIDTH);
		
		gInfo.separator();
		
		lblText = gInfo.label("");
		
		gInfo.separator();
		
		lblMoves = gInfo.label("");
		
		gInfo.separator();
		
		lblStepScore = gInfo.label("");
		
		gInfo.separator();
		
		lblTypeGoal = gInfo.label("");
		
		gInfo.separator();
		
		lblNumSquareValid = gInfo.label("");
		
		gInfo.separator();
		
		hei = Std.int(gInfo.getHeight());
	}
	
	public function update() {
		lblText.set("Level : " + le.actualLevel.level);
		lblMoves.set("Moves : " + le.actualLevel.numMoves);
		lblStepScore.set("Steps Score : - " + le.actualLevel.arStepScore[0] + " - " + le.actualLevel.arStepScore[1] + " - " + le.actualLevel.arStepScore[2]);
		
		lblTypeGoal.set("TypeGoal : " + Type.enumConstructor(le.actualLevel.type));
		
		var n = 0;
		for (s in ModGrid.arSquare)
			if (s != null && s.hsMainBE != null && s.hsMainBE.groupName.indexOf("hole") != -1)
				n++;
		numSquareValid = (Settings.GRID_WIDTH * Settings.GRID_HEIGHT) - n;
		lblNumSquareValid.set("Num Squares Playable : " + numSquareValid);
		
		hei = Std.int(gInfo.getHeight());
	}
}