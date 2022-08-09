class ac.Rail extends Action{//}

	var text:String;
	function new(d){
		super(d)
		//data = downcast(primedata)
	}
	
	function init(){
		super.init();
		Cs.log(text)
		kill();
	}


//{
}