class kaluga.bar.Timer extends kaluga.Bar{//}

	//
	
	// VARIABLES
	var flAutoUpdate:Boolean;
	var startValue:Number;
	var time:Number;
	
	// REFERENCES
	var fieldMin:TextField;
	var fieldSec:TextField;
	var fieldMil:TextField;
	
	function Timer(){
		this.init();
	}
	
	function init(){
		//_root.test+="timerInit();"
		this.width = 120;
		this.flAutoUpdate = false;
		super.init();
	}
	
	function setTimer(t){
		var min,sec,mil;
		min = Math.floor(t/60000)
		sec = Math.floor((t-(min*60000))/1000)
		mil = Math.round((t-(min*60000+sec*1000))/10)
		min = min.toString();
		sec = sec.toString();
		mil = mil.toString();
		if(min.length<2)min="0"+min
		if(sec.length<2)sec="0"+sec
		if(mil.length<2)mil="0"+mil
		
		this.fieldMin.text = min
		this.fieldSec.text = sec
		this.fieldMil.text = mil
	}
	
	function update(){
		super.update();
		if(this.flAutoUpdate){
			var now = getTimer();
			this.time = now-this.startValue
			this.setTimer(this.time);
		}
		//_root.test = now-this.startValue;
	}
	
	function decal(n){
		_root.test+="decal("+n+")"
		this.startValue+=n
	}
	
	function startTimer(){
		this.startValue = getTimer();
		this.flAutoUpdate = true;
	}
	
	function stopTimer(){
		this.flAutoUpdate = false;
	}
	
//{	
}