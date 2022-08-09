class Rafale{//}

	var cooldown:float;
	volatile var w:int;
	var dx:float
	var dy:float
	var cInert:float;

	var list:Array< { type:int, params:Array<float>, cooldown:float } >
	var b:Bads;

	var index:int;
	volatile var timer:float;

	var orientRay:float;


	function new(bad){
		list = new Array();
		b = bad;

		w = 1;
		cooldown = 200;
		dx = 0;
		dy = b.ray;
	}

	function init(){
		index = 0;
		timer = 0;
		b.rafale = this;
		b.shootTimer = cooldown;
	}

	function update(){
		timer -=Timer.tmod;
		if(timer<=0){
			var si = list[index]
			shot(si.type,si.params)
			timer += si.cooldown;
			index++
			b.fire.gotoAndPlay("2");
			if(index == list.length ){
				b.rafale=null;
			}
		}
	}

	function addShot( n, a, cd, max ){
		if(max==null)max =1;
		for( var i=0; i<max; i++ ){
			list.push( {type:n,params:a,cooldown:cd} )
		}
	}

	function shot(type,a){
		var shot = null;
		switch(type){
			case 0: // FRONT (  speed, skin, ray )
				shot = newShot();
				shot.vy = a[0]
				shot.setSkin(a[1],1)
				if(a[2]!=null)shot.ray = a[2]
				break;

			case 1:	// STANDARD (  speed, acc )
				shot = newAimedShot(a[0],a[1]);
				shot.setSkin(13,1)
				break;

			case 2: // CIBLE (  speed, skin )
				shot = newAimedShot(a[0],0);
				shot.setSkin(a[1],1)
				shot.orient();
				break;

			case 3: // MULTI (  speed, skin, nb, pa )
				for( var i=0; i<a[2]; i++){
					var c = (i/(a[2]-1))*2-1
					shot = newAngledShot(a[0],1.57+c*a[3]);
					shot.setSkin(a[1],1)
					//shot.orient();
				}
				break;
			case 4: // FRONT ANGLED ( speed, acc )
				var c = Math.random()*2-1
				shot = newAngledShot(a[0],1.57+c*a[1]);
				shot.setSkin(13,1)
				break;
		}
		if(cInert!=null){
			shot.vx +=  cInert*b.vx
			shot.vy +=  cInert*b.vy
		}

	}

	function newShot(){
		var shot = new Shot(null)
		shot.x = b.x+dx;
		shot.y = b.y+dy;
		if(orientRay!=null){
			var a = b.getAng(Cs.game.hero)
			shot.x += Math.cos(a)*orientRay
			shot.y += Math.sin(a)*orientRay
		}
		return shot;
	}

	function newAimedShot(speed,da){

		//var shot = newShot();
		//var a = b.getAng(Cs.game.hero) +
		//shot.vx = Math.cos(a)*speed;
		//shot.vy = Math.sin(a)*speed;

		return newAngledShot(speed,b.getAng(Cs.game.hero)+(Math.random()*2-1)*da);

	}

	function newAngledShot(speed,a){
		var shot = newShot();
		shot.vx = Math.cos(a)*speed;
		shot.vy = Math.sin(a)*speed;
		return shot;
	}


//{
}