class ac.piou.Climber extends ac.Piou{//}



	function new(x,y){
		super(x,y)
	}
	
	function isAvailable(){
		return super.isAvailable() && piou.sPower != Piou.CLIMBER
	}
	
	function init(){
		piou.setSupaPowa(Piou.CLIMBER)
		kill();
	}
	


	
	
//{
}