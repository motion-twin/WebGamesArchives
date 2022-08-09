class spell.Base{//}

	var flCast:bool;
	var flBusy:bool;
	var flShoot:bool;
	var cost:int;
	//
	var sid:int;
	
	// CASTER
	var fi:FaerieInfo;
	var caster:sp.People
	
	
	function new(){
		flCast = false;
	}
	
	
	function init(){
		
	}
	
	function store(){
		Cs.game.saList.push(this);
		Cs.game.sList.push(this);
		flBusy = true;
	}
	
	function cast(){
		flCast = true;
		caster.incMana(-cost)
		if( caster.currentSpell != null ){
			caster.currentSpell.emergencyStop()
		}
		caster.currentSpell = this;
	}
	
	function update(){
			
	}	
	
	
	function activeUpdate(){
		
	}
	
	function getRelevance():float{
		return 1;
	}
	
	function checkCost(f){
		return caster.mana > cost
	}
		

	function isAvailable(){
		return fi.fs.$mana >= cost && !flBusy;
	}
	
	function sortByScore(result){
		var r:Array<{score:float}> = Std.cast(result)
		var f = fun(a,b){
			if(a.score > b.score ) return -1;
			if(b.score > a.score ) return 1;
			return 0;
		}
		r.sort(f)	
	}
	//
	
	function dispel(){
		caster.currentSpell = null;
		flBusy = false;
		Cs.game.sList.remove(this)
	}
	
	function endActive(){
		fi.react(Lang.spellCheerList);
		// HERE
		flCast = false;
		Cs.game.saList.remove(this)
	}
	
	function finishAll(){
		caster.flForceWay = false;
		caster.trg = null;
		endActive();
		dispel();	
	}
	
	function emergencyStop(){
		finishAll();
	}
	
	//
	function onUpkeep(){
						
	};
	
	//
	function getName(){
		return "noSpellName "
	}
	
	function getDesc(){
		return "noDescription "
	}
	
	function getMsg(){
		var msg = new Msg(getDesc())
		msg.type = 2
		msg.title ="("+cost+")"+getName()+":"
		msg.picFrame = sid+1
		return msg
	}
	
	// TOOLS
	function slowCaster(c){
		var frict = Math.pow( c, Timer.tmod );
		caster.vitx *= frict;
		caster.vity *= frict;	
	}
		
	function centerCaster(){
		casterGoTo( Cs.game.width*0.5, Cs.game.height*0.5 )
	}
	
	function casterGoTo(x,y){
		caster.trg = { x:x, y:y }
		caster.flForceWay = true;	
	}
	
	function isCasterReady(lim){
		if( lim == null )lim = 6;
		return caster.getDist( caster.trg ) < lim
	}
	
	function getRemoveValue(e){

		switch( e.et ){
			
			case Cs.E_TOKEN:
				var token:sp.el.Token = downcast(e)
				switch( token.special ){
					case 0:
						return 0.5
					case 1:
						return 0.6
					case 2:
						return 0.85
			
				}
				break;
				
			case Cs.E_STONE:
				return downcast(e).life*0.4;
				
			case Cs.E_CELL:
				return Math.pow((downcast(e).level+1),1.5);
			case Cs.E_BOMB:
				return 0.9;
			case Cs.E_ITEM:
				return 0;
			case Cs.E_EYE:
				return 1
				
		}
		
		return null;
	}
	
	// FX
	function newOnde(){
		var p = Cs.game.newPart("partLightCircle",null)
		p.x = caster.x;
		p.y = caster.y;
		p.timer = 16
		p.vits = 30
		p.scale = 6
		p.fadeTypeList = [1]
		p.init();
		return p;
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
//{	
}