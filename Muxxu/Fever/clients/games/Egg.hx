


class Egg extends Game{//}

	// CONSTANTES
	var ray:Float;
	var gl:Float;

	// VARIABLES
	var flGround:Bool;
	var flMiss:Bool;
	var flStop:Bool;
	var px:Float;
	var angle:Float;
	var decal:Float;
	var index:Int;
	var pList:Array<Sprite>;

	// MOVIECLIPS
	var egg:Phys;
	var nid:flash.display.MovieClip;


	override function init(dif:Float){
		gameTime = 400-dif*200;
		super.init(dif);
		ray = 7;
		flGround = false;
		flMiss = false;
		angle = 0;
		decal = 0;
		index = 0;
		gl = Cs.omch-8;
		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("egg_bg", 0);
		

		// NID
		nid = dm.attach("mcNid",Game.DP_SPRITE);
		nid.y = gl;

		//* POUTRES
		var last = {x:Cs.omcw*0.5,width:50};
		var max = 3;
		pList = new Array();
		for( i in 0...max) {
			var sp = newSprite("McPoutre");
			var w = 0.0;
			var x = 0.0;
			var y = 0.0;

			while(true){
				w = 80-(dif*40);
				w+= Math.random()*w*0.5;
				x = w*0.5 + Math.random()*(Cs.omcw-w);
				y = 50 + (Cs.omch-50)*(i/max);
				var dx = Math.abs(x-last.x);
				if( dx > (last.width-w)+50-dif*0.3 && dx < (last.width+w)*0.5 ) break;
			}


			sp.width = w;
			sp.vr = 0;
			sp.x = x;
			sp.y = y;

			// SIZE
			var free:McPoutre = cast sp.root;
			
			free.b.mask_.scaleX = (sp.width-4)*0.01;
			free.b.x = -(sp.width-4)*0.5;
			free.s0.x = free.b.x;
			free.s1.x = -free.b.x;
			

			sp.updatePos();
			last = cast sp;
			pList.push(sp);

		}

		var dec = 20;
		if( last.x > Cs.omcw*0.5 ){
			nid.x = last.x - (dec+last.width*0.5);
		}else{
			nid.x = last.x + (dec+last.width*0.5);
		}


		//*/

		// EGG
		egg = newPhys("McEgg");
		egg.x = pList[index].x;
		egg.y = pList[index].y-10;
		egg.weight = 1;
		egg.root.stop();
		egg.updatePos();

	}

	override function update(){
		super.update();
		switch(step){
			case 1:

				var next = pList[index];
				
				// ROTATE NEXT
				if( next != null ){
					var ta = ((getMousePos().x/Cs.omcw)*2-1)*0.6;
					var da = ta - angle;
					angle += da*0.15;
					next.root.rotation = angle / 0.0174;
				}

				// MOVE EGG
				decal = decal+egg.vx*12;
				while( decal > 314 ) decal -= 628;
				while( decal < -314 ) decal += 628;

				egg.root.rotation = (decal / 100) / 0.0174;
				
				var mc:McEgg = cast egg.root;
				mc.light.rotation = -mc.rotation;

				var r = ray;
				var brake = 0;
				if( decal > 157 || decal < -157 ){
					var c = Math.abs(decal/157)-1;
					r += r*c*0.65;
					if(flGround)egg.vx  -= (decal/157)*0.1;
				}

				if(!flGround) {
						var ca = Math.sin(angle) / Math.cos(angle);
						var cb = 0.0;
						if( next != null ) cb = next.y - ca*next.x;
						
						var x = egg.x;
						var y = egg.y+ray;

						if( y > ca * x + cb ) {
							var test = false;
							if( next != null ) test = next.getDist( { x:x, y:y } ) < next.width * 0.5;
							if( test ){

								if(flMiss){
									breakEgg();
									egg.vy *= - 0.2;
								}else{
									land();
								}
							}else{
								setNext();
								flMiss = true;
							}
						}
					

					if( y > gl ){
						egg.weight = 0;
						egg.y = gl-r*0.5;
						egg.vx = 0;
						egg.vy = 0;
						if( Math.abs( x - nid.x ) < 10 ){
							var mask = dm.attach("mcNidMask",Game.DP_SPRITE);
							mask.x = nid.x;
							mask.y = nid.y;
							egg.root.mask = mask;
							setWin(true,20);
							step = 2;
						}else{
							breakEgg();

						}
					}
				}


				if(flGround){
					egg.vx += angle;
					egg.vx *= 0.92;
					
					var test = false;
					if( next != null ) test = egg.getDist(next) < next.width * 0.5;
					
					if( test ){

						var dx = egg.x;
						if( next != null ) dx = egg.x - next.x;
						
						var ds = dx/Math.cos(angle);

						var y = Math.sin(angle)*ds;

						egg.y = y - r;
						
						if( next != null ) egg.y += next.y ;
						
					}else{
						initFall();
						setNext();
					}
					
				}

				// MOVE PLATEFORME
				for(i in 0...index ){
					var p = pList[i];
					if( p == null ) continue;
					p.vr += -p.root.rotation*0.05;
					p.vr *= 0.95;
					p.root.rotation += p.vr;
				}


		}
		//
		egg.root.x = egg.x;
		egg.root.y = egg.y;

	}
	


	function land(){
		flGround = true;
		egg.weight = 0;
		egg.vy = 0;
		update();
		egg.updatePos();
	}

	function initFall(){
		//egg.vx *= 1.1
		//egg.vx += speed * pList[index].sens * 0.5
		flGround = false;
		egg.weight = 1;

	}

	function setNext(){
		index++;
		angle = 0;
	}

	function breakEgg(){
		step = 3;
		egg.root.gotoAndPlay("break");
		setWin(false,20);
	}

//{
}


