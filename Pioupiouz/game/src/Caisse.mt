class Caisse extends LevelElement{//}
	
	var id:int;
	var num:int;
	
	function new(mc){
		mc = Cs.game.dm.attach( "mcCaisse" ,Game.DP_PIOU)
		super(mc)
		Cs.game.cList.push(this)
		/*
		)
		//
		weight = 0.3
		//
		bouncer = new Bouncer(this);
		bouncer.frict = 0.3;
		*/
		
	}
	

	function activate(){
		Inter.addAction(Cs.game.actionList[id],num)
		kill();
	}
	
	function kill(){
		Cs.game.cList.remove(this)
		super.kill()
	}
	
	
	
//{
}