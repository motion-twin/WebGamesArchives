import mt.bumdum.Lib ;
import mt.bumdum.Part ;
import mt.bumdum.Sprite ;
import mt.bumdum.Phys ;
import GameData.ArtefactId ;
import Game.GameStep ;



class PickUp {
	
	
	static public var DIST_MIN = 23.0 ;
	
	public var mcTarget : flash.MovieClip ;
	var targetCol: Float ;
	//var timer : Float ;
	var step : Int ;
	public var showWins : Bool ;
	var spriteList : Array<PickPhys> ;
	var explodeList : Array<PickPhys> ;
	var objectList  : Array<{id : ArtefactId, t : Float, q : Int}> ;
	var objectParts : Array<{p : Phys, t : Float, exploded : Bool}> ;
	var target : {x : Float, y : Float} ;
	var dm : mt.DepthManager ;
	
	
	public function new(t : flash.MovieClip, ?pos : {x : Float, y : Float}) {
		mcTarget = t ;
		targetCol = null ;
		step = null ;
		spriteList = new Array() ;
		//explodeList = new Array() ;
		objectList = new Array() ;
		objectParts = new Array() ;
		showWins = true ;
		
		target = if (pos != null) pos else Const.SPIRIT_CENTER ;
		
		dm = if (Game.me.step == GameOver) Game.me.rdm else Game.me.mdm ;
	}
	
	
	public function init() {
		step = 0 ;
		//timer = 100.0 ;
	}
	
	
	public function addParts(a : Array<Phys>, aid : ArtefactId, t : Float, ?q : Int) {		
		for (p in a) {
			var pp = new PickPhys(p, target) ;
			spriteList.push(pp) ;
		}
		
		if (showWins)
			objectList.push({id : aid, t : t, q : q}) ;
		
		if (step == null)
			init() ;
	}
	
	
	public function update() {
		if (step == null)
			return ;
		
		if (spriteList.length > 0) {
			for (sp in spriteList.copy()) {
				sp.update() ;
				
				if (sp.getDist(target) > DIST_MIN)
					continue ;
				
				spriteList.remove(sp) ;
				sp.fadeType = 0 ;
				sp.timer = 15 + Std.random(15) ; 
				//explodeList.push(sp) ;
					
				if (targetCol == null)
					targetCol = 100.0 ;
			}
		}
		
		
		if (objectParts.length > 0) {
			for (op in objectParts.copy()) {
				if (op.p == null || op.p.root == null || op.t == 100.0) {
					objectParts.remove(op) ;
					continue ;
				}
				
				if (op.p.sleep > 0.0)
					continue ;
				
				if (!op.exploded) {
					op.exploded = true ;
					explode() ;
				}
				
				op.t =  Math.min((op.t * Math.pow(1.1, mt.Timer.tmod)) + 1, 100) ;
				Col.setPercentColor(op.p.root,100 - op.t, Const.PICK_COLOR) ;
			}
		}
		
		switch(step) {
			case 0 : 
				if (targetCol != null && targetCol >= 0.0) {
					targetCol = Math.max(targetCol - 3.5 * mt.Timer.tmod, 0) ;
					if (mcTarget != null)
						Col.setPercentColor(mcTarget, 100 - targetCol, Const.PICK_COLOR) ;
				}
				
				if (spriteList.length == 0 && targetCol == 0.0) {
					step = 1 ;
					targetCol = 0.0 ;
				}
			
			case 1 : 
				if (objectList.length > 0) {
					var t = objectList[0].t ;
					var sleep = 0 ;
					while (objectList.length > 0 && objectList[0].t == t) {
						var o = objectList.shift() ;
						
						var om = new ObjectMc(o.id, dm, Const.DP_PART, null, o.q) ;
						
						var p = new OmcPhys(om.mc) ;
						p.omc = om ;
						p.x = target.x - 15.0 ;
						p.y = target.y - 15.0 ;
						p.weight = -0.25 ;
						p.vy = 2 ;
						p.fadeType = 4 ;
						p.timer = 30 ;
						p.sleep = sleep ;
						
						Col.setPercentColor(p.root, 100, Const.PICK_COLOR) ;
							
						objectParts.push({p : cast p, t : 0.0, exploded : false}) ;
							
						sleep += 20 ;
					}
				} else {
					if (showWins)
						explode() ;
				}
				
				step = 2 ;
			
			case 2 : 
				if (spriteList.length > 0)	
					init() ;
			
				if (objectParts.length > 0)
					return ;
			
				
				targetCol =  Math.min((targetCol * Math.pow(1.08, mt.Timer.tmod)) + 2, 100) ;
				if (mcTarget != null)
					Col.setPercentColor(mcTarget,100 - targetCol,Const.PICK_COLOR) ;
				
			
				
			
				if (allIsDone())
					kill() ;
			
		}
		
	}
	
	
	public function explode() {
		var hmc = dm.attach("transformCircle", Const.DP_PART) ;
		Col.setPercentColor(hmc, 100, Const.PICK_COLOR) ;
		
		hmc._alpha = Math.random() * 60 + 40 ;
		var halo = new Phys(hmc) ;
		halo.x = target.x ;
		halo.y = target.y ;
		halo.setScale(30) ;
		halo.vsc = 1.3 ;
		halo.timer = 8 ;
		halo.fadeType = 6 ;
				
		//parts go to target
		for(i in 0...6) {
			var mc = dm.attach("transformPart", Const.DP_PART) ;
			if (Std.random(3) == 0)
				mc.blendMode = "overlay" ;
			Col.setPercentColor(mc, 100, Const.PICK_COLOR) ;
			var sp = new Phys(mc) ;
			var a = Math.random()*6.28 ;
			
			var speed = 4 + Math.random() * 8 ;
			sp.x = target.x +(Math.random() * 2 - 1) * 14 ;
			sp.y = target.y + (Math.random() * 2 - 1) * 14 ;
			sp.frict = 0.9 ;
			sp.scale = 50 + Math.random() * 50 ;
			sp.fadeType = 0 ;
			sp.timer = 5 ;
			
			a = sp.getAng(target) ;
			var d = sp.getDist(target) ;
			var c = Math.max(1, 16 - d) ;
			sp.vx = -Math.cos(a) * c ;
			sp.vy = -Math.sin(a) * c ;
			sp.vsc = 1.05 ;
		

			var p = PickPhys.newPart(dm) ;
			p.x = target.x +(Math.random()*2-1)*14 ;
			p.y = target.y +(Math.random()*2-1)*14 ;
			p.vx = sp.vx ;
			p.vy = sp.vy ;
		}
	}
	
	
	function allIsDone() {
		return targetCol == 100.0 && spriteList.length == 0 && objectList.length == 0 && objectParts.length == 0 ;
	}
	
	
	public function nearAllIsDone() {
		return step == 2 && targetCol > 50.0 && spriteList.length == 0 && objectList.length == 0 && objectParts.length == 0 ;
	}
	
	
	function kill() {
		
		Game.me.picks.remove(this) ;
	}
	
	
}




class PickPhys extends Phys{//}


	static var ACC = 0.6 ;
	static var FRICT = 0.95 ;

	public var angle : Float ;
	public var color : Int ;
	var ca : Float ;
	var turn : Float ;
	var speed : Float ;
	public var trg: {x : Float, y : Float} ;

	var decal : Float ;
	var speedDecal : Float ;
	var ecart : Float ;




	public function new(p : Phys, t) {
		super(p.root) ;
		
		trg = t ;

		angle = Math.random() * 6.28 ;
		ca = 0.1;
		turn = 0.1;
		speed = 0;
		frict = p.frict ;
		x = p.x ;
		y = p.y ;
		vx = p.vx ;
		vy = p.vy ;
		vr = p.vr ;
		fr = p.fr ;
		vsc = p.vsc ;
		sleep = p.sleep ;
		timer = p.timer ;
		alpha = p.timer ;
		weight = p.weight ;
		fadeLimit = p.fadeLimit ;
		fadeType = p.fadeType ;
		
		Sprite.spriteList.remove(p) ;
		
		decal = Math.random()*6.28;
	}

	override public function update() {

		var ox = x;
		var oy = y;

		// ONDULE
		decal = (decal+64)%628;
		angle += Math.cos(decal*0.01)*0.15 ;

		// FOLLOW
		var dx = trg.x - x;
		var dy = trg.y - y;
		var da = Num.hMod( Math.atan2(dy,dx)-angle, 3.14 ) ;
		angle += Num.mm(-turn,da*ca,turn);
		x += Math.cos(angle)*speed;
		y += Math.sin(angle)*speed;
		speed += ACC;
		speed *= FRICT;
		ca = Math.min(ca+0.01,1);
		turn = Math.min(turn+0.01,1);
		

		// UPDATE
		super.update();

		
		var dx = trg.x - x;
		var dy = trg.y - y;
		var dist = Math.sqrt(dx*dx+dy*dy);
		var lim = 25 ;
		if(dist<lim){
			var c = 1-dist/lim;
			x += c*dx;
			y += c*dy;
		}
		



	}

	
	static public function newPart(?dm : mt.DepthManager){
		var p = new Phys(dm.attach("partTwinkle",Const.DP_PART));
		p.root.gotoAndPlay(Std.random(p.root._totalframes)+1);
		p.timer = 10+Math.random()*25;
		p.setScale(50+Math.random()*100);
		p.fadeType = 0;
		return p;
	}

}



class OmcPhys extends Phys { //dispose bmp on phys kill
	
	public var omc : ObjectMc ;
	
	override public function kill() {
		if (omc != null && omc.mc != null)
			omc.mc.removeMovieClip() ;
			
		super.kill() ;
	}
	
	
	public override function update(){
		var oldSleep = sleep ;
		
		super.update() ;
	}
	
	
}
