package manager;

/**
 * ...
 * @author Tipyx
 */

enum State {
// CLASSIC
	SInit;
	SIdle;
	SSwitch;
	SSolver;
	SFall;
	SGrip;
	SRegen;
	SRegenFull;
	SEndBonus;
	SEndGame;
// SPECIAL
	SSpecial;
	SMagma;
	SWater;
	SBombCiv;
	SPattern;
	SGeyser;
}
 
class StateManager
{
	var game					: process.Game;
	
	public var arQueueState		: Array<State>;

	public function new() {
		game = process.Game.ME;
		
		arQueueState = [];
	}
	
	public function init() {
		arQueueState = [State.SInit];
	}
	
	function changeState() {
		arQueueState.shift();
		if (arQueueState.length == 0)
			arQueueState = [State.SIdle];
		trace(arQueueState[0]);
		switch (arQueueState[0]) {
			case State.SInit :
			case State.SIdle :
				game.clickIsEnable = true;
				game.enableClick();
			case State.SSwitch :
			case State.SSolver :
				Rock.CHECK_SOLVER();
				//Rock.NEW_SOLVER();
			case State.SFall :
				Rock.FALL();
			case State.SGrip :
				//Rock.GRIP();
			case State.SRegen :
				if (game.isEndGame)
					Rock.NEW_REGEN([], true, false, true);
				else
					Rock.NEW_REGEN([], false, true, true);
			case State.SRegenFull :
				Rock.REGEN_FULL();
			case State.SSpecial :
				Rock.SPECIAL_AT_END();
			case State.SMagma :
				SpecialManager.MAGMA();
			case State.SWater :
				SpecialManager.WATER();
			case State.SBombCiv :
				SpecialManager.BOMB_CIV_CD();
			case State.SPattern :
				SpecialManager.PATTERN();
			case State.SGeyser :
				SpecialManager.GEYSER();
			case State.SEndGame :
			case State.SEndBonus :
		}
	}
	
	public function update() {
		//trace(arQueueState);
		switch(arQueueState[0]) {
			case State.SIdle	:
				game.clickIsEnable = true;
				
			case State.SInit, State.SSwitch, State.SSolver, State.SRegenFull,
				State.SFall, State.SRegen, State.SEndBonus, State.SPattern :
				game.clickIsEnable = false;
				var b = true;
				for (r in Rock.ALL)
					if (r != null && r.isAnimated)
						b = false;
				
				if (b)
					changeState();
					
			case State.SBombCiv :
				game.clickIsEnable = false;
				var b = true;
				for (r in Rock.ALL)
					if (r != null && r.isAnimated)
						b = false;
				
				if (b) {
					if (SpecialManager.BOMBCIV_EXPLODED)
						game.showEnd(false);
					else
						changeState();
				}
					
			case State.SMagma :
				game.clickIsEnable = false;
				var b = true;
				for (m in SpecialManager.AR_MAGMA)
					if (m.isTweening)
						b = false;
				
				for (r in Rock.ALL)
					if (r != null && r.isAnimated)
						b = false;
				
				if (b)
					changeState();
				
			case State.SGrip :
				//if (game.grip == null || !game.grip.isPicking)
					//changeState();
					
			case State.SGeyser :
				game.clickIsEnable = false;
				var b = true;
				
				for (g in SpecialManager.AR_GEYSER)
					if (g.isTweening)
						b = false;
				
				for (r in Rock.ALL)
					if (r != null && r.isAnimated)
						b = false;
				
				if (b)
					changeState();
					
			case State.SWater :
				game.clickIsEnable = false;
				changeState();
			case State.SSpecial :
				game.clickIsEnable = false;
				changeState();
				
			case State.SEndGame :
				game.clickIsEnable = false;
		}
	}
}