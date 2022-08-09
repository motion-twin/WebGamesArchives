import mt.bumdum.Lib;
typedef Label = { >flash.MovieClip, field:flash.TextField, timer:Float, sy:Int, dec:Float, col:Int }

class Phys extends Sprite {//}


	public var ray:Float;
	public var frict:Float;
	public var vx:Float;
	public var vy:Float;
	public var vr:Float;

	public var mcLabel:Label;
	//public var blink:Float;

	public function new(mc){
		super(mc);
		vx = 0;
		vy = 0;
		ray = 1;

	}

	public function update(){

		if(vr!=null)root._rotation += vr;
		if(frict!=null){
			vx*=frict;
			vy*=frict;
		}

		x += vx;
		y += vy;

		super.update();
		if(mcLabel!=null)updateLabel();
	}

	/*
	// ROBERT
	public function setBlink(){
		blink = 0;
	}
	public function updateBlink(){
		blink = (blink+113)%628;
		var st = (Math.cos(blink*0.01))*4;
		root.filters = [];
		Filt.glow(root,5,1+st,0xFF0000);

		var r = ray + 10;
		mcLabel._x = x;
		mcLabel._y = y - r;
	}
	*/

	public function setLabel(col,?str:String,?timer){
		if(str!=null){
			mcLabel = cast Game.me.dm.attach("mcLabel",Game.DP_FX);
			mcLabel._x = -1000;
			mcLabel.field.text  = str.toUpperCase();
			mcLabel.smc._width = mcLabel.field.textWidth+6;
			mcLabel.field._width = mcLabel.smc._width+10;
			mcLabel.field._x = -mcLabel.field._width*0.5;
			mcLabel.timer = timer;
			mcLabel.sy = -1;
			mcLabel.dec = 10;
			mcLabel.col = col;
			Col.setPercentColor( mcLabel.smc, 100, col );
			if(col==0xFFFFFF)mcLabel.field.textColor = 0x222266;
			Filt.glow(mcLabel,2,0,0);
		}
		Filt.glow(root,4,4,col);

	}
	public function updateLabel(){
		mcLabel._x = x;
		mcLabel._y = y + (ray+mcLabel.dec)*mcLabel.sy;
		if( mcLabel.timer!=null ){
			mcLabel.timer--;
			var c = mcLabel.timer/10;
			if(c<1){
				mcLabel._alpha = c*100;
				if(mcLabel.timer<0)	mcLabel.removeMovieClip();
				root.filters = [];
				var gl = c*4;
				Filt.glow(root,gl,gl,mcLabel.col);
			}

		}
	}

	public function addToVictims(){
		var dx = Game.me.htrg.x - x;
		var dy = Game.me.htrg.y - y;
		Game.me.victims.push( {p:this,ray:Math.sqrt(dx*dx+dy*dy)} );

	}

	public function warp(){
		var mc = Game.me.dm.attach("mcWarp",Game.DP_FX);
		mc._x = x;
		mc._y = y;
		mc._xscale = mc._yscale = 40+ray*5;
		kill();
	}
	public function kill(){
		mcLabel.removeMovieClip();
		super.kill();
	}


//{
}





