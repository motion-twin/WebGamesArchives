class inter.Score extends Inter{//}

	
	
	
	function new(b){
		super(b);
		height = 20;
		width = 100;	
		//init();
	
	}
	
	function init(){
		link = "interScore";
		super.init();
	}
	
	function setScore(score:int){
		Std.cast(skin).field.text = score;
	} 
	
	
	
	
	
	
	
//{
}