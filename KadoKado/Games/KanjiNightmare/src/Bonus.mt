class Bonus extends Sprite{//}


	static var UNIQUE:int;

	var id:int;
	var time:float;

	function new(mc) {
		super(mc);
		Cs.game.bonusList.push(this)
		time = 300;
	}

	function update(){
		time-=Timer.tmod;
		if(time<10){
			root._alpha=time*10
			if(time<0)kill();
		}

		super.update();

	}

	function setId(n){
		if( n==25 || n==8 ){
			if(UNIQUE==null)UNIQUE = n;
			else n = UNIQUE;

		}


		id=n;
		root.gotoAndStop(string(id))
	}

	function take(){
		var pid = null
		var sc = null;
		switch(id){
			case 1:
				sc = Cs.C200
				pid = 0
				break;
			case 2:
				sc = Cs.C1000
				pid = 0
				break;
			case 3:
				sc = Cs.C5000
				pid = 0
			case 4:
				Cs.game.hero.incStar(20)
				pid = 1
				break;
			case 5:
				Cs.game.hero.incStar(50)
				pid = 1
				break;
			case 6:
				Cs.game.hero.incKunai(1)
				pid = 1
				break;
			case 7:
				Cs.game.hero.hpUp()
				pid = 1
				break;
			case 8:
				Cs.game.hero.initAura()
				pid = 1
				break;
			default:
				Cs.game.hero.optList[id-20] = true
				Cs.game.hero.updateIcons();
				pid = 1
				if(id==24){
					Hero.SPEED*=1.5;
				}

				break;


		}
		//

		switch (pid){
			case 0:
				for(var i=0; i<12; i++ ){
					var p = Cs.game.newPart("partSpark")
					var a = Math.random()*6.28
					var d = Math.random()*(6+18*(1-(i/24)))
					p.x = root._x + Math.cos(a)*d
					p.y = root._y + Math.sin(a)*d
					p.timer = 10+Math.random()*10
					p.wait = Math.max(0,Math.pow(i*30,0.5)-8)
					p.setScale(30+Math.random()*100 - p.wait*2)
				}
				break;
			case 1:
				for(var i=0; i<3; i++ ){
					var p = Cs.game.newPart("partCircle")
					p.x = root._x
					p.y = root._y
					p.root._rotation = Math.random()*360
					p.timer = 18-i*3
					p.vs = 6+i*8
					p.vr = 8+i*12
				}
				break;
			case 2:
				var max = 8
				for( var i=0; i<max; i++ ){
					for( var n=0; n<2; n++ ){
						var p = Cs.game.newPart("partLight")
						p.x = root._x
						p.y = root._y
						var a = ((i+0.5*n)/max)*6.28
						var speed = (3+n*2)
						p.vx += Math.cos(a)*speed
						p.vy += Math.sin(a)*speed
						p.timer = 26+Math.random()*4-n*10
						p.frict = 0.9
					}

				}
				break;

		}

		if(sc!=null){
			if(Cs.game.hero.optList[3])sc = KKApi.cmult( sc, KKApi.const(2) );
			addScore(sc);
		}

		Cs.game.stats.$opt[id-1]++

		kill();

	}

	function addScore(n){
		Cs.game.genScore(root._x,root._y,n);
		/*
		KKApi.addScore(n)
		var p = Cs.game.newPart("mcScore")
		p.x = root._x;
		p.y = root._y;
		p.vy = -1
		p.timer = 24
		downcast(p.root).field.text = string(KKApi.val(n))
		Cs.glow(downcast(p.root).field,4,2,0)
		*/
	}

	function kill(){
		Cs.game.bonusList.remove(this);
		root.removeMovieClip();
	}


//{
}









