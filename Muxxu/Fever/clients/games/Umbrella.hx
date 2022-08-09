import Protocole;
import mt.bumdum9.Lib;
typedef UmbShur = {>Phys, ggy:Float, state:Int };
class Umbrella extends Game{//}

	static var GY = 340;


	var depths:Array<Int>;
	var startCoef:Float;
	var catSpeed:Float;
	var shurikenSpeed:Float;
	var ray:Float;
	var freq:Float;
	var wind:Float;

	var ground:flash.display.MovieClip;
	var shurikens:List<UmbShur>;
	var cat:{>flash.display.MovieClip,tx:Null<Float>,wait:Int};
	var umb:Phys;
	var shade:flash.display.MovieClip;
	var ol:Array<flash.display.MovieClip>;

	var gdm:mt.DepthManager;

	override function init(dif:Float){
		gameTime =  320;
		super.init(dif);

		catSpeed = 1+dif*4;
		shurikenSpeed = 60;
		ray = 110-dif*40;
		freq = 0.25+dif*0.25;
		wind = (Math.random()*2-1)*0.25;

		startCoef = 0;

		shurikens = new List();
		attachElements();

	}

	function attachElements(){
		bg = dm.attach("umbrella_bg",0);

		// SHADE
		shade =  dm.attach("umbrella_shade",0);
		shade.y = GY;

		// GROUND
		ground = dm.empty(Game.DP_SPRITE);

		// DEPTHS
		depths = [];
		for( i in 0...400 )if(i<200 || i>202)depths.push(i);


		
		gdm = new mt.DepthManager(ground);
		
		// CAT
		//cat = cast dm.attach("umbrella_cat",Game.DP_SPRITE);
		//cat = cast ground.attachMovie("umbrella_cat","cat",201);
		cat = cast gdm.attach("umbrella_cat",200);
		cat.x = Cs.mcw*0.5;
		cat.y = GY;
		cat.wait = 20+Std.random(20);
		cat.stop();

		// UMB
		umb = new Phys( gdm.attach("umbrella_tool",201) );
		umb.x = Cs.mcw*0.5;
		umb.y = Cs.mch*0.5;
		umb.setScale(ray*0.02);
		umb.frict = 0.95;


	}

	override function update(){
		super.update();
		startCoef = Math.min(startCoef+0.01,1);

		freq += 0.001;
		if(Math.random()<freq*Math.pow(startCoef,4) && gameTime<380 )addShuriken();

		switch(step){
			case 1:
				moveUmb();
				moveCat();
			case 2:
				moveUmb();
			case 3:


		}
		moveShurikens();
		
	}

	function moveCat(){
		if( cat.wait-->0 )return;
		if( cat.tx == null ){
			var ma = 30;
			cat.tx = ma + Std.random(Cs.mcw-2*ma);
		}
		var dx = cat.tx - cat.x;
		cat.x += Num.mm(-catSpeed,dx*0.5,catSpeed);
		cat.scaleX = (dx>0)?1:-1;

		if( Math.abs(dx)<1 ){
			cat.tx = null;
			cat.wait = 10+Std.random(30);
		}
		cat.play();

	}

	function moveUmb() {
		var mp = getMousePos();
		var dx = mp.x - umb.x;
		var dy = mp.y+40*(ray*0.02) - umb.y;

		var lim = 30;
		umb.x += Num.mm(-lim,dx*0.25,lim);
		umb.y += Num.mm(-lim,dy*0.25,lim);


		var lim = 320;
		if( umb.y > lim ){
			var dx = cat.x - umb.x;
			if(Math.abs(dx)<28 && (umb.vy>5 || (dy>80 && gameTime<300)) && step==1 ){
				Reflect.setField(cat,"_disp",true);
				cat.gotoAndPlay("shuriken");
			
				setWin(false,20);
				step = 3;
				umb.vy = 14;
				umb.frict = 0.7;
				cat.x = umb.x;
				var mask = dm.attach("umbrella_mask",0);
				mask.x = umb.x;
				mask.y = GY-5;
				umb.root.mask = mask;

			}else{
				umb.vy *=0.5;
				umb.y = lim;
				umb.updatePos();
			}
		}

		shade.x = umb.x;




	}

	function addShuriken(){

		var di = Std.random(depths.length);
		var d = depths[di];
		depths.splice(di,1);
		var sp:UmbShur =  cast new Phys( gdm.attach("umbrella_shuriken",d) );
		sp.x = Math.random()*Cs.mcw;
		sp.y = -(10+Math.random()*80);
		var a = 1.57 + wind;
		sp.vx = Math.cos(a)*shurikenSpeed;
		sp.vy = Math.sin(a)*shurikenSpeed;
		sp.ggy = GY + (d-200)*0.07;
		sp.state = 0;
		getSmc(getSmc((sp.root))).stop();
		cast(sp.root).queue.scaleY = shurikenSpeed*0.02;
		cast(sp.root).queue.rotation = wind/0.0174;
		shurikens.push(sp);
	}
	function moveShurikens(){
		for( sp in shurikens ){
			switch(sp.state){
				case 0:
					var lim = umb.y-ray*1.5;
					if( sp.y > lim ){
						sp.state = 1;
						var dx = umb.x-sp.x;
						if( Math.abs(dx)<ray ){


							//
							sp.state = 2;
							sp.y = lim;
							sp.vx = (dx*0.3);
							sp.vy = -(4+Math.random()*10);
							sp.weight = 0.3;
							sp.vr = (Math.random()*2-1)*60;
							sp.updatePos();
							getMc(sp.root,"queue").visible = false;
							if(step==1)umb.vy += 3+dif*2;


							// FX
							var fx = dm.attach("fx_roundImpact",Game.DP_PART);
							fx.x = sp.x;
							fx.y = sp.y;
							fx.rotation = Math.random()*360;
							fx.blendMode = flash.display.BlendMode.ADD;
						}
					}
			}


			// GROUND
			if(sp.y>sp.ggy){

				var dx = cat.x-sp.x;
				if( Math.abs(dx)<30 && step==1 && sp.state == 1 ){
					cat.gotoAndPlay("shuriken");
					setWin(false,20);
					step = 2;
				}else{

					sp.root.y = sp.ggy;
					var mcc = getSmc(getSmc((sp.root)));
					mcc.gotoAndStop(2);
					new mt.fx.GotoAndStop(mcc,untyped __unprotect__("smc"),Std.random(3));
					getMc(sp.root,"queue").play();
					sp.root = null;
				}
				sp.kill();
				shurikens.remove(sp);

			}
		}

	}


	override function outOfTime(){
		setWin(true);
	}



//{
}

