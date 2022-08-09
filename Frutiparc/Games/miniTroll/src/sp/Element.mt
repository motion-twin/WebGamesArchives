class sp.Element extends Sprite{//}

	var flFront:bool;
	var flFalling:bool;
	var flDestroy:bool;
	var px:int;
	var py:int;
	var et:int;
	
	var link:String;
	
	var game:Game;
	
	function new(){
		super();
	}
	
	function init(){
		super.init();
		var d = Game.DP_SPRITE
		if( flFront ) d = Game.DP_SPRITE_FRONT;
		skin = game.dm.attach( link, d )
		setScale(game.ts)
		game.eList.push(this)
		game.insertInGrid(this);
		updatePos()
		updateSkin();
	}
	
	function updateSkin(){
		//skin._xscale = skin._yscale = game.ts;
		if(Cs.base.elementColor!=null){
			Mc.setPercentColor(skin,Cs.base.elementColor.prc,Cs.base.elementColor.col)
		}
	}
	
	function setSkin(mc){
		super.setSkin(mc)
		//Mc.setPercentColor(skin,20,0x0000FF)
	}
	
	function setScale(scale){
		skin._xscale = skin._yscale = scale;
	}
		
	function initDefault(){
		super.initDefault()
		flFalling = false;
		px = 0;
		py = 0;
	}
	
	function update(){
		super.update();
	}

	function activeUpdate(){
	
	};
	
	function haveGround(){
		if(py+1>=game.yMax)return true;
		var e = game.grid[px][py+1]
		return e!=null && !e.flFalling
	}
	
	function updatePos(){
		x = game.getX(px)
		y = game.getY(py)
		update();
	}
		
	function kill(){
		for(var i=0; i<game.eList.length; i++ ){
			if(game.eList[i]==this){
				game.eList.splice(i,1)
				break;
			}
		}
		game.removeFromGrid(this)
		super.kill();
	}
	
	function blast(){
	
	}
	
	function isolate(){
	
	}
	
	function initActiveStep(){
	
	}
	
	// TOOL
	function morphToPart(){
		isolate();
		var p = game.newPart("echec",null)
		p.x = x
		p.y = y
		p.scale = game.ts
		p.setSkin(skin)
		skin = null;
		kill();
		return p
	}
	// FX
	function fxCrystal(){
		
	}
	
	function quake(){
		var o = {
			sp:this,
			pos:{x:x,y:y},
			ray:3,
			timer:10,
			fadeLimit:10
		}
		Cs.game.quakeList.push(o)	
	}
	
	function roundBlink(){
		Std.attachMC(skin,"partRoundBlink",10)
	}
	
	function explode(){
	
	}
	
	
	
	/*
	function isSameCycle(e){
		for( var i=0; i<cList.length; i++ ){
			for( var n=0; n<e.cList.length; n++ ){
				if( cList[i] == e.cList[n] ) return true;
			}
		}
		return false;
	}
	*/
	
	

//{
}