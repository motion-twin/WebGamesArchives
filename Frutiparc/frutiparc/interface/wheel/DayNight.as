class wheel.DayNight extends Wheel{//}

	var dayCoef:Number;
	var aidCheck:Number;
	var firstCheck:Boolean;
	
	function DayNight(){
		this.firstCheck = false;		
		this.init()
	}
	
	function init(){
		this.wheelId=0;
		super.init();

	}

	function wheelInit(){
		
		super.wheelInit();
		
		var initObj = {
			link:"police",
			num:"21:37",
			scale:85,
			_y:52
		}
		this.skin.mc.display.attachMovie("extGameNumb","hour",1,initObj)
		this.updateDayCoef();
		
		// premier appel juste après le changement de minute
		var now = _global.servTime.getDateObject()
		var s = 60 - now.getSeconds();
		this.firstCheck = true;
		this.aidCheck = setInterval(this,"updateDayCoef",s * 1000 + 500);

	}	
	
	function updateDayCoef(){
		if(this.firstCheck){
			// on passe à un appel toutes les minutes
			this.firstCheck = false;
			clearInterval(this.aidCheck);
			this.aidCheck = setInterval(this,"updateDayCoef",60000)
		}
		var now = _global.servTime.getDateObject()
		var h = now.getHours();
		var m = now.getMinutes();
		this.dayCoef = (h+m/60)/24;
		this.setRot(this.dayCoef*360) ;
		
		if(String(h).length<2)h="0"+h;
		if(String(m).length<2)m="0"+m;
		this.skin.mc.display.hour.setNum(h+":"+m)
		//_root.test+="this.dayCoef : "+this.dayCoef+"(h:"+h+",m:"+m+")\n" ;
		

		
		//this.skin.mc.display.field.text = h+":"+m
		

	}
	
	function setRot(deg){
		super.setRot(deg)
		this.skin.mc.display._rotation = - deg
	}
	
	function onBaseTurn(){
		this.skin.mc.display._rotation = -( this._rotation+this._parent._rotation )
	}

	function kill(){
		clearInterval(this.aidCheck)
		super.kill();
	}
	
	
	
//{
}