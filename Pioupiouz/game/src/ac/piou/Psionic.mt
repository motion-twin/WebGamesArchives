class ac.piou.Psionic extends ac.Piou{//}



	function new(x,y){
		super(x,y)
	}
	
	function isAvailable(){
		return super.isAvailable() && piou.sPower != Piou.PSIONIC
	}
	
	function init(){
		piou.setSupaPowa(Piou.PSIONIC)
		kill();
	}
	


	
	
//{
}