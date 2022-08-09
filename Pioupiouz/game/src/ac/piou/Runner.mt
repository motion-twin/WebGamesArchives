class ac.piou.Runner extends ac.Piou{//}



	function new(x,y){
		super(x,y)
	}
	
	function isAvailable(){
		return super.isAvailable() && piou.sPower != Piou.RUNNER
	}
	
	function init(){
		piou.setSupaPowa(Piou.RUNNER)
		kill();
	}
	


	
	
//{
}