import mt.bumdum9.Lib;

typedef KCKiwi = {>flash.display.MovieClip, zz:Float, vz:Float, c:Float, shade:flash.display.MovieClip, cs:Float };

class KiwiCut extends Game{//}

	var timer:Int;
	var speed:Float;
	var delay:Float;

	var kiwis:List<KCKiwi>;
	var knife:flash.display.MovieClip;

	override function init(dif:Float){
		gameTime =  340-100*dif;
		super.init(dif);
		kiwis = new List();
		timer = 30;
		speed = 0.005 + dif*0.025;
		delay = 50-dif*34;
		attachElements();
	}

	function attachElements(){

		bg = dm.attach("kiwiCut_bg",0);
		//bg.onPress = cut;
		

		// KNIFE
		knife = dm.attach("kiwiCut_knife",1);
		knife.x = 16;
		knife.stop();

	}

	override function onClick() {
		cut();
	}
	
	override function update() {
		
		
		if(timer--<0 && gameTime>100-dif*70 ){
			timer = Std.int( delay+Math.random()*delay );
			genKiwi();
		}
		updateKiwis();
		super.update();
		if( gameTime<=0 && kiwis.length==0 ){
			setWin(true);
		}
	}

	function cut(){
		if(knife.currentFrame>1)return;
		knife.gotoAndPlay(2);
		fxShake(8);

		for( mc in kiwis ){
			if( mc.c>0.7 && mc.c<0.8 ){

				for( i in 0...2 ){
					var sens = i*2-1;
					var p = new Phys(dm.attach("KiwiCut_part",1+i));
					p.x = mc.x;
					p.y = mc.y;
					p.vx = sens*(0.5+Math.random()*3);
					p.vy = -(3+Math.random()*6);
					p.vr = (Math.random()*2-1)*4;
					p.frict = 0.97;
					p.fr = 0.95;
					p.root.gotoAndStop(2-i);
					p.weight = 0.5;
					p.updatePos();
					p.setScale(mc.scaleX);
				}

				mc.shade.parent.removeChild(mc.shade);
				mc.parent.removeChild(mc);
				kiwis.remove(mc);

				dm.over(knife);


			}
		}

	}


	function genKiwi(){

		var mc:KCKiwi = cast dm.attach("kiwiCut_kiwi",2);
		mc.c = 0;
		mc.zz = -(60+Math.random()*80);
		mc.vz = 0;
		mc.x = -100;
		mc.cs= 0.9+Math.random()*0.2;

		mc.shade = dm.attach("kiwiCut_shade",0);
		mc.shade.x = -100;

		kiwis.push(mc);

	}
	function updateKiwis(){
		for( mc in kiwis ){

			mc.c = Math.min(mc.c+speed*mc.cs,1);
			var c = Math.pow(mc.c,2);
			var sc = 0.6+c*0.8;


			//
			var ray = 40*sc;

			//
			mc.vz += 0.5;
			mc.zz += mc.vz;
			if(mc.zz>-ray){
				mc.zz = -ray;
				mc.vz *=-1;
			}

			//
			mc.x = -40 + 540*c;
			mc.y = 280 + 160*c;
			mc.scaleX = mc.scaleY = sc;


			mc.shade.x = mc.x;
			mc.shade.y = mc.y;
			mc.shade.scaleX = mc.shade.scaleY = sc;

			mc.y += mc.zz*sc;



			if(mc.c==1){
				mc.parent.removeChild(mc);
				kiwis.remove(mc);
				setWin(false);

			}


		}
	}

	override function outOfTime(){

	}


//{
}

















