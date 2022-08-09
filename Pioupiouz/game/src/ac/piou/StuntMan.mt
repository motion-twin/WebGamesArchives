class ac.piou.StuntMan extends ac.Piou{//}



	function new(x,y){
		super(x,y)
	}
	
	function isAvailable(){
		return super.isAvailable() && piou.sPower != Piou.STUNTMAN
	}
	
	function init(){
		piou.setSupaPowa(Piou.STUNTMAN)
		kill();
	}
	


	
	
//{
}