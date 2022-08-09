class kaluga.AnimList{//}
	
	var list:Array;
	
	/*-----------------------------------------------------------------------
		Function: AnimList()
		constructeur
	------------------------------------------------------------------------*/
	function AnimList(){
		this.init();
	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	------------------------------------------------------------------------*/
	function init(){
		this.list = new Array()
	}	
	
	/*-----------------------------------------------------------------------
		Function: addAnim(name,id,endCall)
	------------------------------------------------------------------------*/
	function addAnim(name,id,endCall){
		//_root.test+="[animList] addAnim("+name+")\n"
		for(var i=0; i<this.list.length; i++){
			var anim = this.list[i]
			if(anim.name == name){
				clearInterval(anim.id)
				anim.id = id;
				anim.endCall=endCall
				return;
			}
		}
		this.list.push({name:name,id:id,endCall:endCall});
	}
	
	/*-----------------------------------------------------------------------
		Function: addAnim(name,id,endCall)
	------------------------------------------------------------------------*/
	function remove(name){
		//_root.test+="[animList] remove("+name+")\n"
		for(var i=0; i<this.list.length;i++){
			var anim = this.list[i]
			if(anim.name == name){
				
				anim.endCall.obj[anim.endCall.method](anim.endCall.args)
				clearInterval(anim.id)
				this.list.splice(i,1)
				return;
			}	
		}
	}

	/*-----------------------------------------------------------------------
		Function: removeAll()
	------------------------------------------------------------------------*/
	function removeAll(){
		while(this.list.length>0){
			var anim = this.list[0]
			clearInterval(anim.id)
			this.list.shift()
		}
		
	};

	/*-----------------------------------------------------------------------
		Function: addSlide(name,target,endCall,ratio)
	------------------------------------------------------------------------*/
	function addSlide(name,target,endCall,ratio){
		
		if(target.regular==undefined){
			target.regular = new Object()
		}
		target.regular.x = target._x
		target.regular.y = target._y
		if(ratio==undefined)ratio=1;
		this.addAnim(name,setInterval(this,"slide",25,name,target,ratio),endCall);
	}
	
	/*-----------------------------------------------------------------------
		Function: slide(name,mc,ratio)
	------------------------------------------------------------------------*/
	function slide(name,mc,ratio){
		
		//_root.test+="l"
		
		var c = Math.pow(0.8,kaluga.Cs.tmod*ratio);
		mc.regular.x = mc.regular.x*c + mc.pos.x*(1-c)
		mc.regular.y = mc.regular.y*c + mc.pos.y*(1-c)
		mc._x = mc.regular.x
		mc._y = mc.regular.y
		if(Math.round(mc.regular.y)==Math.round(mc.pos.y) and Math.round(mc.regular.x)==Math.round(mc.pos.x)){
			mc._x = mc.pos.x
			mc._y = mc.pos.y
			this.remove(name)
		};
		if(mc.followList.length>0){
			for(var i=0; i<mc.followList.length; i++){
				var mc2 = mc.followList[i]
				mc2._x = mc._x;
				mc2._y = mc._y;
			}
		};
	};
	
	/*-----------------------------------------------------------------------
		Function: addPaint(name,mc,color,percent,endCall,ratio)
	------------------------------------------------------------------------*/
	function addPaint(name,mc,color,percent,endCall,ratio){
		
		if(mc.colorObject==undefined)kaluga.MC.setPColor(mc)
		
		mc.colorObject.target = {
			col:color,
			percent:percent	
		}

		if(ratio==undefined)ratio=1;
		this.addAnim(name,setInterval(this,"paint",25,name,mc,ratio),endCall);
	}
	
	/*-----------------------------------------------------------------------
		Function: paint(name,mc,ratio)
	------------------------------------------------------------------------*/
	function paint(name,mc,ratio){
		
		var c = Math.pow(0.8,kaluga.Cs.tmod*ratio);
		var act = mc.colorObject.actual
		var targ = mc.colorObject.target
		
		act.col.r = act.col.r*c + targ.col.r*(1-c)
		act.col.g = act.col.g*c + targ.col.g*(1-c)
		act.col.b = act.col.b*c + targ.col.b*(1-c)
		
		act.percent = act.percent*c + targ.percent*(1-c)
		
		//_root.test+="r:"+act.percent+"\n"
		
		kaluga.MC.setPColor(mc)
		
		if(Math.abs(act.percent - targ.percent) + Math.abs(act.col.r - targ.col.r) + Math.abs(act.col.g - targ.col.g) + Math.abs(act.col.b - targ.col.b) <4 ){
			this.remove(name);
		}
	};
	
//{	
}

