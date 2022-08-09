class ac.Piou extends Action{//}
	
	var flExclu:bool;
	var flSameIsOk:bool;
	var piou:Piou
	var baseSens:int;
	
	static var psionicList:Array<Piou>
	
	function new(x,y){
		super(x,y)
		flSameIsOk = false;
	}

	function isAvailable(){
		piou = getNearest(18)
		return piou!=null
	}
	
	function init(){
		super.init();
		
		//Log.trace("!initAction : piou("+int(piou.x)+","+piou.y+") btimer("+Cs.game.btimer+")")
		
		
		if(piou.currentAction!=null){
			piou.currentAction.interrupt();
		}
		piou.currentAction = this;
		downcast(piou.root).action = this;
		baseSens = piou.sens
		piou.initStep(Piou.ACTION)
		
		
		if(piou.sPower==Piou.PSIONIC && psionicList== null){
			psionicList = new Array();
			for( var i=0; i<Cs.game.pList.length; i++ ){
				var p = Cs.game.pList[i]
				if( p.sPower==Piou.PSIONIC && p!= piou ){
					psionicList.push(p)
				}

			}
			
			for( var i=0; i<psionicList.length; i++ ){
				var p = psionicList[i];
				var o = Inter.getActionSlot(Inter.cid)
				var ac = Cs.game.getAction(Inter.cid,Cs.game.map._xmouse,Cs.game.map._ymouse)
				downcast(ac).piou = p;
				if( isSelectable(p) ){
					ac.init();
					Inter.updateActionSlot(o)
				}				
			}
			psionicList = null
		}
		
		// GFX
		if(Cs.game.flMouseAction){
			var p = Cs.game.newPart("partAction")
			p.x = piou.x
			p.y = piou.y - Piou.RAY
			p.updatePos();
			if(Cs.game.flPause)p.root.stop();
		}
	}
	
	function isSelectable(p:Piou){
		return  ( p.step == Piou.WALK || p.step == Piou.ACTION ) && (p.currentAction.id != id || p.currentAction.flSameIsOk ) && p.currentAction.flExclu!=true && p.noSelection == null && p.gid==1
	}

	function getNearest(lim){
		var select:Piou = null;
		var min = lim
		var priority = 0;
		for( var i=0; i<Cs.game.pList.length; i++ ){
			var piou = Cs.game.pList[i]
			var dx = piou.x - tx
			var dy = (piou.y-Piou.RAY) - ty
			var dist = Math.sqrt(dx*dx+dy*dy)
			var flSelect = false;
			var sp = 0
			if( isSelectable(piou) ){
				/*
				if( piou.currentAction != null ) sp+=2;
				if( piou.sPower!=null ) sp+=1;
				
				if( sp > priority ){
					flSelect = dist < lim;
				}else if( sp == priority ){
					flSelect = dist < min
				}
				*/
				
				if( piou.currentAction != null ){
					if( select.currentAction != null ){
						flSelect = dist < min
					}else{
						flSelect = dist < lim;
					}
				}else{
					if( select.currentAction == null ){
						flSelect = dist < min
					}
				}
			}
			if( flSelect ){
				min = dist
				select = piou
				priority = sp
			}
		}
		return select;
	}
	
	function kill(){
		freePiou();
		super.kill()
	}
	
	function freePiou(){
		if(piou.currentAction == this){
			piou.currentAction = null;
			if(piou.sens!=baseSens)piou.reverse();
			piou = null;
		}
	}
	
	function checkGround(m,d){
		if(m==null)m=2;
		if(d==null)d=0;
		for( var i=-m; i<m; i++ ){
			if( !Level.isFree(int(piou.x+i+d),int(piou.y+1)) ){
				return true;
			}
		}
		piou.fall();
		return false;
		
		
	}
		
	function go(){
		if(piou!=null){
			if(piou.currentAction==this)piou.initWalk();
			freePiou();
		}
	}
	
	function isCur(){
		return piou.currentAction == this;
	}
	
 //{
}