class miniwave.sp.bads.Titi extends miniwave.sp.Bads {//}

	var flPunchReady:Array;
	var punchList:Array;
	
	function Titi(){
		this.init();
	}
	
	function init(){
		this.freq = 240
		this.coolDownSpeed = 20		
		this.type = 22;
		super.init();
		this.punchList = new Array();
		this.flPunchReady = [true,true]
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		this.endUpdate();
	}
	
	function shoot(){
		for(var i=0; i<2; i++){
		
			if(this.flPunchReady[i]){
				this.punch(i)
				return;
			}
		}		
	}
	
	function punch(id){
		//if(id==1)_root.test+="punch("+id+")";
		if( this._currentframe != 2 ) this.gotoAndStop(2);
		var mc = super.shoot();
		mc.vity = 10
		mc.behaviourInfo = {
			id:id,
			step:0,
			path:this		
		}
		mc.behaviourId = 4;
		mc.killMargin = 100
		this.punchList[id] = mc;
		this["p"+(id+1)]._visible = false;
		this.flPunchReady[id] = false;
		
		
		
	}
	
	function returnPunch(id){
		this["p"+(id+1)]._visible = true;
		this.punchList[id] = undefined
		this.flPunchReady[id] = true;
		

		if(this.getPunchNb()==2)this.gotoAndStop(1);
		
	};
	
	function kill(){
		for(var i=0; i<2; i++){
			var p = this.punchList[i].vanish();
		}
		super.kill();
	}
	
	function explode(){
		super.explode(3+this.getPunchNb())
	}
	
	function getPunchNb(){
		var n = 0;
		for(var i=0; i<2; i++){
			if(flPunchReady[i]){
				n++;
			}
		}
		return n;		
	}
	
//{
}