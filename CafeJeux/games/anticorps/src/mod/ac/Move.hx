package mod.ac;
import Common;
import mt.bumdum.Lib;



class Move extends mod.Action{//}


	var flJumpReady:Bool;

	var walkTimer:Float;
	var stack:Array<Int>;
	var mcArrow:flash.MovieClip;


	public function new(?cosmo) {
		super(cosmo);
		stack = [];
		walkTimer = 0;
	}

	override function init(){
		mcArrow = cosmo.dm.attach("mcArrow",0);
		mcArrow.stop();
		cosmo.flAutoTurnHead = true;
	}
	override function remove(){
		Game.me.setMsg();
		mcArrow.removeMovieClip();
		sendStack();
	}


	// UPDATE
	override function update(){

		//MMApi.print("mod.ac.Move");

		super.update();
		if(flMenu)return;


		var mp = getMousePos();
		var mdist = Math.sqrt(mp.x*mp.x+mp.y*mp.y);
		var a =  Math.atan2(mp.y,mp.x);

		var ray = 24;
		mcArrow._x = cosmo.head.x + Math.cos(a)*ray;
		mcArrow._y = cosmo.head.y + Math.sin(a)*ray;
		mcArrow._rotation = a/0.0174;


		// CHECK MOVE TYPE
		var moveType = null;
		var da = Num.hMod(a-cosmo.ga,3.14) ;

		var frame = null;
		for( i in 0...2 ){
			var sens = i*2-1;
			if(  Math.abs(da-1.57*sens) < 0.8  ){
				moveType = sens;
				frame = 2;
			}
			if( Math.abs(da)<0.77){
				moveType = 0;
				frame = 3;
			}

		}
		if(moveType==null)frame = 1;
		//if(moveType==null)mcArrow.gotoAndStop(1);

		if( mcArrow._currentframe != frame ){
			mcArrow.gotoAndStop(frame);
			switch(frame){
				case 1: Game.me.setMsg("Mouvement impossible.");
				case 2: Game.me.setMsg("Cliquez pour avancer");
				case 3: Game.me.setMsg("Cliquez pour sauter");
			}
		}






		// APPLY MOVE
		if( mdist>40 && ( moveType==-1 || moveType==1 ) && Game.me.flClick ){

			stackPush(moveType);
			cosmo.walk(moveType);

			if( !cosmo.checkBalance() ){
				//trace("FALL!");
				sendStack();
				//var a = cosmo.getNormal();
				MMApi.queueMessage( PlayJump( cosmo.ga, 1.5));
				kill();
				return;
			}


			/*
			if( cosmo.checkBalance() ){
				stackPush(moveType);
			}else{
				cosmo.walk(-moveType);
				cosmo.setSens(-cosmo.sens);
				mcArrow.gotoAndStop(1);
			}
			*/


			if( cosmo.applyDanger() ){
				//trace("DANGER!");
				sendStack();
				//Game.me.checkMines(cosmo.x,cosmo.y);
				Game.me.endAnim =  Game.me.pass;
				kill();
			}

		}

		// MOVE INTERRUPT CHECK
		if(flDeath)return;


		if( moveType==0 ){
			if( !flJumpReady && !Game.me.flClick )flJumpReady = true;
		}else{
			flJumpReady = false;
		}

		// JUMP
		if( flJumpReady && Game.me.flClick && moveType==0){
			sendStack();
			MMApi.queueMessage( PlayJump( a, cosmo.jumpPower));
			kill();

		// NO MORE TIME
		}else if(cosmo.escapeTimer==0){
			sendStack();
			cosmo.timeUp();
			kill();
		}
	}

	// STACK
	function stackPush(n){
		stack.push(n);
		if(stack.length>100)sendStack();
	}
	function sendStack(){
		var a = getStack();
		if(a!=null)MMApi.queueMessage(PlayStack(a));
	}
	function getStack(){
		if(stack.length==0)return null;

		var list = [2,cosmo.x,cosmo.y,cosmo.gid];

		for( p in cosmo.pods ){
			list.push(p.dec);
			list.push(p.gid);
			list.push(p.x);
			list.push(p.y);
		}

		// USE FOR RECONNECT FAST RECAL
		// for(n in list )stack.push(n);

		var a = stack.copy();
		stack = [];
		return a;
	}

	//
	override function kill(){

		if(stack.length>0)trace("mod.ac.Move Kill Error ! Stack not empty !");
		super.kill();
	}







//{
}











