class kaluga.bar.Score extends kaluga.Bar{//}

	// CONSTANTES
	var scale:Number = 100 
	
	// MOVIECLIPS
	var score:kaluga.Numb;
	
	
	function Score(){
		this.init();
	}
	
	function init(){
		//_root.test+="[Score] init()\n"
		super.init();
	}
	
	function initDefault(){
		if( this.width == undefined )this.width = 160;
		super.initDefault();
	}
		
	function setScore(score){
		//_root.test+="[Score] setScore("+score+")\n"
		this.attachMovie("numb","score",1,{num:score,scale:this.scale,align:2,link:"numberGreen"})
		this.score._y = this.margin.x.ratio*this.margin.x.min + 15*(this.scale/100)
		this.score._x = -this.margin.y.ratio*this.margin.y.min
	}	
	
	
//{
}