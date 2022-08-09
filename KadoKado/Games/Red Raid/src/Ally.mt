class Ally extends Arrow{//}

	static var sel:Array<Ally>


	var flSelectable:bool;

	var cd:float;
	var range:float
	var view:float
	var damage:float
	var rate:float
	var swivel:float;

	var ox:float;
	var oy:float;
	var giveup:float;
	var light:float;

	var selector:MovieClip;




	function new(mc){

		flSelectable = true;
		Cs.game.aList.push(this)
		Cs.game.bounceList.push(this)
		mc = Cs.game.dm.attach("mcAlly",Game.DP_UNITS)
		super(mc)
		//root.onPress = callback(this,selectOne)

		//
		cd = 0

	}

	function initSkin(){
		super.initSkin();
		shadow = Cs.game.dm.attach("mcAllyShadow",Game.DP_SHADOW)
		shadow.gotoAndStop(string(type+1))
	}

	function update(){
		super.update();
		cd-=Timer.tmod;
		if(wp!=null){
			follow();
			giveup += 1.5*Timer.tmod;
			giveup -= Math.abs(ox-x)+Math.abs(oy-y)
			ox = x
			oy = y
			if(giveup>4){
				wp = null;
			}
		}
		//
		var trg = findTrg();
		if(trg!=null){
			faceTrg(trg)
			if(cd<=0){
				attack(trg);
			}
		}

		checkBound()

		if(light!=null){
			Cs.setPercentColor(root,light,0xFFFFFF)
			light=(light-1)*0.9
			if(light<1){
				light = null;
				Cs.setPercentColor(root,0,0xFFFFFF)
			}

		}
		if(selector!=null){
			selector._x = x;
			selector._y = y;
		}


	}

	function setWaypoint(pos){
		super.setWaypoint(pos);
		giveup = 0
		ox = x
		oy = y
	}

	function checkBound(){
		if( x<ray || x>Cs.mcw-ray ){
			x = Cs.mm(ray,x,Cs.mcw-ray)
			vx = 0
		}
		if( y<ray || y>Cs.mch-ray ){
			y = Cs.mm(ray,y,Cs.mch-ray)
			vy = 0
		}
	}

	function faceTrg(trg){
		towardAngle(getAng(trg))
	}

	function findTrg(){
		var max = 1/0
		var trg = null
		for( var i=0; i<Cs.game.bList.length; i++ ){
			var bad = Cs.game.bList[i]
			var dist = getDist(bad)
			var flValide = (dist < bad.ray + ray + range) && dist<max
			if( flValide && wp != null ){
				var da = Cs.hMod(getAng(bad)-angle,3.14)
				if(Math.abs(da)>swivel){
					flValide = false;
				}
			}

			if(  flValide ){
				trg = bad
				max = dist
			}

		}
		return trg
	}

	function attack(trg){

		cd = rate;
		var a = getAng(trg)

		// IMPACT
		var mc = Cs.game.dm.attach("partImpact",Game.DP_PART)
		mc._rotation = a/0.0174
		mc._x = trg.x+(Math.random()*2-1)*trg.ray*0.8;
		mc._y = trg.y+(Math.random()*2-1)*trg.ray*0.8;
		mc._xscale = 100
		mc._yscale = mc._xscale

		// RECUL
		var rec = 5*trg.mass/Timer.tmod;
		trg.vx += Math.cos(a)*rec
		trg.vy += Math.sin(a)*rec

		//
		trg.hit(damage,a);


	}

	function kill(){
		sel.remove(this);
		if(selector!=null)selector.removeMovieClip();
		Cs.game.aList.remove(this)
		Cs.game.bounceList.remove(this)
		super.kill();
	}

	function hit( damage, a ){
		showLife();
		lifePanelTimer = 30



		super.hit(damage,a)




	}


	function die(ba){
		if(type<3){
			var sp = new Part(Cs.game.dm.attach("mcCadaver",Game.DP_BONUS))
			sp.x = x;
			sp.y = y;
			sp.root._rotation = root._rotation
			sp.root.gotoAndStop(string(type+1))
			sp.timer = 50+Math.random()*10
		}
		super.die(ba)
	}

	// SELECTION

	static function flushSelect(){
		while(sel.length>0){
			sel.pop().selector.removeMovieClip();
		}
	}

	function addToSel(){
		sel.push(this)
		selector = Cs.game.dm.attach("mcSelectRound",Game.DP_SELECTOR)//Std.attachMC(root,"mcSelectRound",1)
		selector._x = x;
		selector._y = y;
		selector.gotoAndStop(string(type+1))
	}

	function selectOne(){
		flushSelect();
		addToSel()
	}


//{
}