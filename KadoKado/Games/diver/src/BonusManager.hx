package ;
import Game;
import Diver;

enum TypeBonus {
	BUMP;
	PACMAN;
	BOMB;
	ACC;
	TIME;
	STOP_SPAWN;
}



class BonusManager
{//}
	public var cdSpawn		: Int;
	public var cdPacman		: Int;
	public var invul		: Int;
	private var dyB			: Array<Float>;
	private var rangeB		: Array<Float>;
	
	public function new()
	{
		cdSpawn  = 0;
		cdPacman = 0;
		invul 	 = 20;
		rangeB = new Array();
		dyB = new Array();
	}
	
	public function getBonus() {
		var t = [
				BUMP, BUMP, BUMP,
				PACMAN, PACMAN,
				BOMB,
				ACC,
				TIME, TIME, TIME,
				STOP_SPAWN,
				];
		return t[Std.random(t.length)];
	}
	
	public function useBonus( b : TypeBonus, x : Float, y : Float ) {
		switch(b) {
			case BUMP 		:
				invul = 30;
				var angle = Math.atan2(Game.me.player.mc.y - y, Game.me.player.mc.x - x);
				Game.me.player.dy += (Math.abs(Math.sin(angle) * 5))+1 ;
				Game.me.player.dx += (Math.cos(angle) * 5)+1 ;
				
			case PACMAN 	:
				cdPacman += 90;
				for (b in Game.me.bub) {
					b.mc.gotoAndStop(2);
					b.pacmanable = true;
				}
				
			case BOMB 		:
				while (Game.me.bub.length > 0) Game.me.bub.pop().burst();
				Game.me.bub = new Array();
			case ACC		:
				Game.me.speed *= 1.5;
				
			case TIME 		:
				Game.me.timer += 150;
				
			case STOP_SPAWN :
				cdSpawn += 150;
		}
	}
	
	
	public function getColor(t:TypeBonus) {
		switch (t) {
			case BUMP 		: return 0x33FF33;
				
			case PACMAN 	: return 0xFFFF00;
			
			case BOMB 		: return 0xFF0000;
				
			case ACC		: return 0x9999FF;
				
			case TIME 		: return 0x663300;
				
			case STOP_SPAWN : return 0xCC33CC;
		}
	}
	public function updateBonus() {
		if (Game.me.cdBonus > 0 ) 	Game.me.cdBonus --;
		
		if (cdSpawn > 0) {
			cdSpawn --;
			slowBub();
			if (cdSpawn == 30) {
				for (b in 0...Game.me.bub.length) {
					Game.me.bub[b].dy = dyB[b];
					Game.me.bub[b].range = rangeB[b];
				}
			}
			if (cdSpawn <= 30 && cdSpawn > 0) {
				for (b in 0...Game.me.bub.length) {
					Game.me.bub[b].dy *= 1.2;
					Game.me.bub[b].range *= 1.2;
				}
			}
			if (cdSpawn == 0) {
				for (b in Game.me.bub) {
					b.dy = - ((Math.random() * Game.me.level + 1.0 +Math.random()))*0.7;
				}
			}
		}
			
		
		if (cdPacman > 0) {
			cdPacman --;
			if (cdPacman == 0) {
				for (b in Game.me.bub) {
					b.mc.gotoAndStop(0);
					b.pacmanable = false;
				}
			}
		}
		if(invul > 0)	invul 	 --;
	}
	
	public function getText(t:TypeBonus) {
		switch(t) {
			case BUMP 		: return "J";
			
			case PACMAN 	: return "P";
		
			case BOMB 		: return "B";
			
			case ACC		: return "AC";
			
			case TIME 		: return "T";
			
			case STOP_SPAWN : return "S";
		}
	}
	
	private function slowBub() {
		for (b in 0...Game.me.bub.length) {
			Game.me.bub[b].dy *= 0.9;
			Game.me.bub[b].range *= 0.9;
			if (cdSpawn == 120) {
				dyB[b] = Game.me.bub[b].dy ;
				rangeB[b] = Game.me.bub[b].range ;
				Game.me.bub[b].dy = 0;
				Game.me.bub[b].range = 0;
			}
		}
	}
	
	
	
	
	

	//{
}