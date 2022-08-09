class miniwave.panel.Score extends MovieClip{//}

	var score:Number;
	var field:TextField;
	var b1:MovieClip;
	var b2:MovieClip;
	
	var game:miniwave.Game
	
	function Score(){
		this.init();
	};
	
	function init(){
				
		
	};
	
	function setScore(score){
		this.score = score;
		this.field.text = score;
		
		var tw = this.field.textWidth
		
		//this.b1._xscale = tw
		//this.b2._xscale = tw
		
		this.b2._x = tw+6
		
		this._x = (this.game.mng.mcw-tw)/2
		
	}
	
	function update(){
	
		
	}
	
	
//{	
}