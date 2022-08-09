class kaluga.InfoBar extends MovieClip{//}

	
	var eNum:Number;
	var list:Array;
	
	
	function InfoBar(){
		this.init();
	}
	
	function init(){
		//_root.test+="[InfoBar] init()\n"
		this.list = new Array();
		this.eNum = 0
	}
	
	function addElement(link,initObj,name,index){
		if( initObj == undefined ) initObj = new Object();
		initObj.infoBar = this;
		var d = (eNum++)%100;
		this.attachMovie(link,"element"+d,d,initObj);
		var mc = this["element"+d];
		if(name==undefined) name == "element"+d;
		/*
		if(index==undefined or index>this.list.length ) index == this.list.length;
		this.list[index] = mc
		*/
		this.list.push(mc)
		this.updatePos();
		return mc;
	}
	
	function removeElement(mc){
		for(var i=0; i<this.list.length; i++){
			if( mc == this.list[i] ){
				this.list.splice(i,1)
				return;
			}
		}
	}
	
	function updatePos(){
		var x = 0
		//_root.test+="[InfoBar] updatePos()\n"
		for(var i=0; i<this.list.length; i++){
			//_root.test+="x ->"+x+"\n"
			var mc:kaluga.Bar = this.list[i];
			mc._x = x;
			x -= mc.width+mc.margin.x.min;
		}
	}
	
	function update(){
		for(var i=0; i<this.list.length; i++){
			this.list[i].update();
		}	
	}		
	
	
	
	
	
	
//{	
}