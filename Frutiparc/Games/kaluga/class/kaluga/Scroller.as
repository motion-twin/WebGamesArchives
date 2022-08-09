class kaluga.Scroller extends MovieClip{//}
	
	// VARIABLE 
	var list:Array;
	var animList:kaluga.AnimList;
	var tNum:Number;
	
	function Scroller(){
		this.init()
	}
	
	function init(){
		//_root.test+="[Scroller] init()\n"
		this.tNum = 0;
		this.list = new Array()
		this.animList = new kaluga.AnimList();
	}
	
	function update(){
	
	}
	
	function put(name,bonus){
		this.list.push({name:name,bonus:bonus});
		if(this.list.length==1)this.displayNext();
	}
	
	function displayNext(){
		var d = (tNum++)%100
		this.attachMovie("scrollText","t"+d,d)
		var mc = this["t"+d]
		mc.nameField.text = this.list[0].name+" "+this.list[0].bonus;
		//mc.bonusField.text = this.list[0].bonus;
		mc.regular = {x:0,y:-40}
		mc.pos = {x:0,y:0}
		mc._x = mc.regular.x
		mc._y = mc.regular.y
		mc.d = d
		this.animList.addSlide("slide"+d,mc,{obj:this,method:"setWait",args:mc})
	}
	
	function setWait(mc){
		mc.waitId = setInterval(this,"remove",1000,mc)
	}
	function remove(mc){
		clearInterval(mc.waitId)
		mc.pos = {x:0,y:-40}
		this.animList.addSlide("slide"+mc.d,mc,{obj:mc,method:"removeMovieClip"})
		this.list.shift();
		if(this.list.length>0)this.displayNext();
	}
	
	
//{
}