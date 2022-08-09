class miniwave.LifePanel extends MovieClip{//}

	// CONSTANTES
	var timerMax:Number = 50
	
	// PARAMETRES
	var size:Number;
	
	// VARIABLE
	var game:miniwave.Game;
	
	var depthRun:Number;
	var timer:Number;
	var mcList:Array;
	var animList:Array;
	
	var moving:Object;
	
	function LifePanel(){
		this.init();
	}
	
	function init(){
		
		if(this.size==undefined) this.size = 8;
		
		this._x = this.game.mng.mcw;
		this._y = this.game.mng.mch;
		this.depthRun = 0
		this.timer = 0
		this.mcList = new Array();
		this.animList = new Array();
		/*
		for(var i=0; i<list.length; i++){
			var id = list[i];

		}
		*/
	}
	
	function addLife(id){
		var d = depthRun++
		this.attachMovie( "miniWave2SpHero"+this.game.mng.heroInfo[id].link,"hero"+d, d );
		var mc = this["hero"+d]
		mc._x = -(mcList.length+0.5)*(this.size+4)
		mc._y = -6
		mc._xscale = (this.size*100)/20
		mc._yscale = (this.size*100)/20
		mcList.push(mc)
	}
	
	function removeLife(){
		this.moving = this.mcList.pop()
	}
	
	function update(){
		if( moving != undefined ){
			var y = 10
			moving._y = moving._y*0.9 + y*0.1
			if( Math.abs(moving._y-y)<5 ){
				this.game.initNextHero();
				delete this.moving;
			}
		}
	}
	

	
//{
}