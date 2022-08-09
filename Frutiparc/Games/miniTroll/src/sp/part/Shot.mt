class sp.part.Shot extends sp.Part{//}
	
	var flOrient:bool;
	
	var type:int;
	var vLim:float;
	var ray:float;
	var damage:float;
	var decal:float;
	
	var angle:float;
	var speed:float;
	var recul:float;
	
	var link:String;
	
	var trg:sp.People;
	var caster:sp.People;
	
	var op:{x:float,y:float};
	
	var trgList:Array<sp.People>;
	var typeList:Array<int>;
	
	var spell:spell.Shot
	
	
	// NON SPECIFIC
	var n0:float;
	
	// SPECIFIC
	var spellTriggerTimer:float
	var queueLink:String;
	var homingInfo:{ va:float, la:float, sleep:float }
	var blobInfo:{ sc:float, dec:float, ds:float, sp:float }
	
	
	
	function new(){
		super();
		
		vLim = 0
		ray = 1
		damage = 0
		recul = 1.5
		trgList = new Array();
		typeList = new Array();
		
		n0=0;
		
	}
	
	function init(){
		super.init();
		/*
		//Cs.game.shotList.push(this)
		//var frame = null;
		switch(type){
			case 0:	 // FAERIE N 1
				//lnk = "shotStandard";
				//damage = 40;
				//ray = 4;
				//initDirect(4)
				break;
			
			case 1:	 // FAERIE N 1
				link = "shotStandard";
				damage = 40;
				ray = 4;
				initDirect(4)
				break;			
			
			
			case 20:
			case 21:
			case 22:
			case 23:
			case 24:

				break;			
		
			
		}
		
		//if(frame!=null)skin.gotoAndStop(string(frame));
		*/
		setSkin(Cs.game.dm.attach(link,Game.DP_PART))
		decal=0;
		
		//list = Cs.game.shotList
		//list.push(this)
		
	}
	
	function initDirect(p){
		speed = p
		angle = getAng(trgList[0])
		
		updateVit()
		
		caster.vitx -= Math.cos(angle)*recul
		caster.vity -= Math.sin(angle)*recul

		friction = 1		
	}
	
	function initHoming(p,va,la,sleep){
		initDirect(p)
		typeList.push(2)
		homingInfo = { va:va, la:la, sleep:sleep}
	}	
	
	function initQueue(link){
		typeList.push(3)
		queueLink = link
	}
	
	function initBlob(sc,ds,sp){
		blobInfo = { sc:sc, dec:0, ds:ds, sp:sp }
		typeList.push(4)
	}
	
	function initSpellTrigger(t){
		spellTriggerTimer = t
		typeList.push(6)
	}
	
	function updateVit(){
		var ca = Math.cos(angle)
		var sa = Math.sin(angle)
		vitx = ca*speed
		vity = sa*speed
	}
	
	function initDefault(){
		super.initDefault();
	}
	
	function update(){
		
		
		checkTarget();
		checkGameBounds();

		if(flOrient)orient();
		
		for( var i=0; i<typeList.length; i++ ){
			var type = typeList[i]
			switch(type){
				case 0:
	
					break;
				case 1:	// WHITE FLOW
					
					var p = getPartFader( 0x00FFFF, Math.random()*ray*1.5 );
					p.timer= 20+Math.random()*20;
					p.init();
					
					break;
					
				case 2:	// HOMING
					var trg = upcast(trgList[0])
					if( trg == null ) trg = { x:Cs.game.width*0.5, y:-40 }
					var da = getAng(trg) - angle
					da = Cs.mm( -homingInfo.la, Cs.round(da,3.14), homingInfo.la )
					angle += da*homingInfo.va*Timer.tmod
					updateVit()
					break;
					
				case 3:	// QUEUE
					queue(queueLink)
					break;
					
				case 4:	// BLOB
					blobInfo.dec = (blobInfo.dec+blobInfo.ds*Timer.tmod)%628
					var ca = Math.cos(blobInfo.dec/100)
					var sa = Math.sin(blobInfo.dec/100)
					skin._xscale = (100 + ca*blobInfo.sc)*scale/100
					skin._yscale = (100 + sa*blobInfo.sc)*scale/100
					if( blobInfo.sp != null ){
						speed += ca*blobInfo.sp
						updateVit();
					}
					break;
					
				case 5:	// FADEIN
					var c = 0.2
					scale = scale*(1-c) + 100*c
					skin._xscale = scale;
					skin._yscale = scale;
					break;	
					
				case 6:	// TRIGGER

					spellTriggerTimer -= Timer.tmod;
					if( spellTriggerTimer <= 0 ){
						spell.trigger(this);
						typeList.splice(i--,1)
					}
					
				case 7:	// SPHERE
					var trg = upcast(trgList[0])
					var a = getAng(trg)
					var dist = getDist(trg)
					var frame = 1+Math.round( Math.min(dist/80, 1)*20 )
					skin.gotoAndStop( string(frame) )
					
					var ca = Math.cos(a)
					var sa = Math.sin(a)
					var sens =((ca>0)?1:-1)
					skin._xscale = sens*100
					skin._rotation = sa*45*sens
					break;	
					
				case 22: // TURN LEFT RIGHT
					decal = (decal+30)%628
					vitr = Math.cos(decal/100)*28
					break;	
					
				case 23: // ONDULATION
					decal = (decal+49)%628
					setVit(angle+Math.sin(decal/100)*0.2,speed)
					orient()
					queue("partQueueStandard")
					break;
					
				case 24: // CREPITE
					var p = getPartFader(0xFF6600,  Math.random()*ray );
					p.timer= n0+5+Math.random()*10;
					p.init();
					break;	
					
				case 30: // BOUNDS
					if( x<ray || x>Cs.game.width-ray ){
						x = Cs.mm(ray,x,Cs.game.width-ray)
						vitx *= -1
						angle = Math.atan2(vity,vitx)
					}
					if( y<ray || y>Cs.game.height-ray ){
						y = Cs.mm(ray,y,Cs.game.height-ray)
						vity *= -1
						angle = Math.atan2(vity,vitx)
					}					
					break;	
			}
		}
		super.update()
		
		
	}
	
	
	function setVit(a,sp){
		vitx = Math.cos(a)*sp
		vity = Math.sin(a)*sp
	}
	
	function checkGameBounds(){
		var xMin = vLim
		var xMax = Cs.game.width-vLim
		var yMin = vLim
		var yMax = Cs.game.height-vLim

		if( x < xMin || x>xMax || y<yMin || y> yMax ){
			kill();
		}	
	}
	
	function checkTarget(){
		if(Cs.game.step!=2)return;
		for(var i=0; i<trgList.length; i++ ){
			var trg = trgList[i]
			if(!trg.flDeath){
				if( getDist(trg) < ray+trg.ray ){
					if(spell!=null)spell.hitTrg(trg,this);
					hit(trg);
				}
			}else{
				trgList.splice(i,1)
			}
		}		
	}
	
	function hit(trg){
		//trg.harm(damage)
		var p = damage*0.1
		var a = Math.atan2(vity,vitx)
		trg.vitx += Math.cos(a)*p
		trg.vity += Math.sin(a)*p
		
		trg.harm(damage)
		
		kill();
	}
		
	function kill(){
		Cs.game.shotList.remove(this)
		super.kill();
	}

	
	// FX
	function getPartFader(color,d){

		var p = Cs.game.newPart("partFader",null)
		var a = Math.random()*6.28
		//var d = Math.random()*ray*1.5
		p.x = x+Math.cos(a)*d
		p.y = y+Math.sin(a)*d
		p.scale = 30+Math.random()*70
		p.weight = 0.01+(p.scale/100)*0.05;
		p.flGrav = true;
		p.timer = 10
		p.fadeColor = color
		p.fadeTypeList = [0,2]
		return p;
		//p.init();

	}
	
	function queue(link){
		if(op==null)op = {x:x,y:y}
		
		var p = Cs.game.newPart(link,Game.DP_PART2)
		p.x = x;
		p.y = y;
		p.skin._rotation = p.getAng(op)/0.0174
		
		p.init()
		p.skin._xscale = p.getDist(op)
		
		op = {x:x,y:y}
		
	}
	
	// TOOLS
	
		
	
//{	
}












