class miniwave.game.Mission extends miniwave.game.Main{//}
	
	var missionNum:Number;
	var prime:Number;
	
	function Mission(){
		_root.test+="[MISSION] init() 2.0\n"
		//this.init();
	}

	function initDecor(){
		super.initDecor();
		this.decor.gotoAndStop(10+missionNum);
		//this.decor.bg0.gotoAndStop(1)
		//this.decor.bg1.gotoAndStop(2)
		this.decor._y = this.mng.mch;
	}
	
	function getEndMsg(){
		var str =  "Mission \""+this.name+"\" réussie!!"
		if(this.getCons()==100 && this.mng.fc[0].$cons.$bonus[this.missionNum] < 100 ){
				str += "Votre prime : "+this.prime+" crédits\n"
				this.incCred(this.prime);
		}
		return str
	}

	function genOptionList(){
		
		this.optionList = [
			40,		// BRONZE 1
			20,		// ARGENT 5
			5,		// GOLD 10
			1,		// PLATINIUM 50
			0,		// WARP 5
			0,		// WARP 10
			0,		// WARP 20
			5,		// CARD RED HANABI
			5,		// CARD GREEN HOMING
			5,		// CARD BLUE WAVE
			8
		
		]
		this.optionPointMax = 0
		for(var i=0; i<this.optionList.length; i++ )this.optionPointMax += this.optionList[i];
		
	}	
	
	function endGame(){
		var p = this.getCons();
		if( p > this.mng.fc[0].$cons.$bonus[this.missionNum] ){
			this.mng.fc[0].$cons.$bonus[this.missionNum] = p
			if( p == 100 ){
				this.mng.client.giveItem("$mis"+this.missionNum);
				this.mng.newTitem++
			}
			this.mng.fc[0].$bonus[this.missionNum] = Math.max( this.mng.fc[0].$bonus[this.missionNum], this.score );
		}
		super.endGame();
	}
	
	function getWaveName(){
		return "mis"+missionNum
	}

	function update(){
		if( this.checkWaveInfoLoading() )return;
		super.update();
	}
	
	// STATS
	function addNewPlay(){
		super.addNewPlay("$mission")
	}
	
//{	
}














