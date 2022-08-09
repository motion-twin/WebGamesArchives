package lander;

import mt.bumdum.Lib;
import mt.bumdum.Phys;

private enum Step  {
	Jump(sens:Int);
	Consume;
}


class Drone extends Phys{//}


	var c:Float;
	var frame:Float;

	var min:lander.Mineral;
	var step:Step;

	var pad:lander.Pad;
	var dec:{x:Float,y:Float};

	var tx:Float;
	var ty:Float;
	public var minVal:mt.flash.VarSecure;


	public function new(){
		var mc = lander.Game.me.bdm.attach("mcDrone",lander.Game.DP_DRONES);
		super(mc);
		pad = lander.Game.me.pad;

		frame = 0;
		root.stop();

	}


	override public function update(){
		super.update();
		switch(step){
			case Jump(sens):	updateJump(sens);
			case Consume:		updateConsume();
		}


	}



	// SEEKER
	public function initModeSeeker(){
		x = pad.x;
		y = pad.y;
		jumpToMineral();
	}

	function getMinPos(){
		dec = min.getPosModifier();
		tx = min.root._x+dec.x;
		ty = min.root._y+dec.y;
	}

	function jumpToMineral(){
		step = Jump(1);
		min = pad.minList[ Std.random( pad.minList.length ) ];
		c = 0;
		getMinPos();
	}
	function updateJump(sens){


		// OLD POS
		var ox = x;
		var oy = y;

		// MOVE
		c = Num.mm(0,c+sens*0.05,1);
		x = pad.x*(1-c) + tx*c;
		y = pad.y*(1-c) + ty*c - Math.sin(c*3.14)*40;


		// QUEUE
		var mc = lander.Game.me.bdm.attach("mcQueueDrone",lander.Game.DP_GROUND);
		mc._x = ox;
		mc._y = oy;
		//trace(mc._x);
		var dx = x-ox;
		var dy = y-oy;
		mc._rotation = Math.atan2(dy,dx)/0.0174;
		mc._xscale = Math.sqrt(dx*dx+dy*dy);

		// ROTATION
		root._rotation = Math.atan2(dy,dx)/0.0174;


		if( c==1 ){
			step = Consume;
		}
		if( c==0 ){
			pad.receiveDrone(this);
			kill();
		}

	}
	function updateConsume(){

		var coef = 0.1;

		var dx = tx - x;
		var dy = ty - y;

		x += dx*coef;
		y += dy*coef;

		var move = Math.abs(dx)+Math.abs(dy);
		if( Std.random(14)==0 || move<1 ) getMinPos();

		// GFX
		frame = ( frame+move*0.25 )%12;
		root.gotoAndStop( Std.int(frame)+1 );
		root._rotation = Math.atan2(dy,dx)/0.0174;

		//
		if( !min.flDeath )min.consume(1);
		if( min.flDeath ){
			minVal = min.val;
			min.val = new mt.flash.VarSecure(0);
			tx = x;
			ty = y;
			step = Jump(-1);
		}




	}









//{
}








