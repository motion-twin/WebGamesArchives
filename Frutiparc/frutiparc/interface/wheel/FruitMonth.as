class wheel.FruitMonth extends Wheel{//}

	
	var aidCheck:Number;
	
	function FruitMonth(){
		this.init();
		
	}
	

	
	function init(){
		this.wheelId=1;
		super.init();
	}

	function wheelInit(){
		super.wheelInit();
		this.aidCheck = setInterval(this,"update",3600000)
		this.update();
			
	}
	
	function update(){
		var s = _global.servTime.getCurrentFSign()
		this.setRot( (s.sign+s.signCompletion)*36 ) ;
		//_root.test += "s.sign("+s.sign+")\n"
		//_root.test += "s.signCompletion("+s.signCompletion+")\n"
		

	}
	
	function kill(){
		clearInterval(this.aidCheck)
		super.kill();
	}
/*
_global.servTime.getCurrentFSign(); 
return un objet avec : 
sign (entier), signb (entier), signCompletion (0-1), signbCompletion (0-1)	
*/
	
	
//{	
}