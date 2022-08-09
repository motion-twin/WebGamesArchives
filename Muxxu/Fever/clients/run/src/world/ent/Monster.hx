package world.ent;
import Protocole;




class Monster extends world.Ent {//}
	
	public var sprite:pix.Sprite;
	var stain:McStain;
	public var data:MonsterData;
	
	public function new(island, sq, mt:Int ) {
		
		super(island, sq);
		type = EMonster;
		block = true;
		island.monsters.push(this);
		
		data = Data.DATA._monsters[mt];


		// SPRITE
		sprite = new pix.Sprite();
		sprite.setAnim(Gfx.monsters.getAnim(data._anim));
		sprite.anim.gotoRandom();
		addChild(sprite);
		
		// STAIN
		stain = new McStain();
		stain.x = x;
		stain.y = y;
		island.dirtMask.addChild(stain);
		//stain.scaleX = stain.scaleY = 3+((sq.ints[0]*0.1) % 5);
		stain.scaleX = stain.scaleY = 3;
		
		
		// DEC
		var dec = 4;
		sprite.y = data._oy;
		y += 4;
	}
	
	public function playRandomAnim() {
		return;
		var a = ["jump","look_left","mouth"];
		var a = ["blob_yellow"];
		sprite.setAnim(Gfx.monsters.getAnim(a[Std.random(a.length)]));
		sprite.anim.loop = true;
		sprite.anim.onFinish = backToNormal;
	}
	
	function backToNormal() {
		sprite.anim = null;
		sprite.drawFrame(Gfx.monsters.get(0,"blob_yellow"));
	}
	
	public override function kill() {
		sprite.kill();
		
		super.kill();
		island.monsters.remove(this);
	}
	
	public function death() {
		kill();
		new fx.CheckIslandGrow(island,stain,sq);
		island.onDestroyMonster();
	}
	
	
	public override function destroy(anim="_explode") {
				
		var p = new pix.Sprite();
		p.x = x+sprite.x;
		p.y = y + sprite.y;
		island.dm.add(p, world.Island.DP_ELEMENTS);
		p.setAnim(Gfx.monsters.getAnim(data._anim + anim ));
		p.anim.onFinish = p.kill;
		//
		death();
	}
	
	public override function trigSide() {
		
		if( !World.me.sendReady() ) {
			World.me.setControl(true);
			return true;
		}
		if( world.Loader.me.havePlay() ) {
			World.me.launchLevel(sq);
		}else {
			world.Inter.me.displayHint(Lang.NO_MORE_ICECUBE);
			World.me.setControl(true);
			var url = new flash.net.URLRequest(Main.noplay);
			flash.Lib.getURL(url,"_self");
		}
		return true;
	}
	
	public override function isTrig() {
		return true;
		//return world.Loader.me.havePlay();
	}
	
//{
}








