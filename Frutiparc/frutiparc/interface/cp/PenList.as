class cp.PenList extends Component{//}
	
	var activeList:Array;
	var animList:AnimList;
	var current:Number; 	// A recuperer autre part au final
		
	/*-----------------------------------------------------------------------
		Format de list
			- text : String
			- list : Array
			- frame : Number ou String
	 ------------------------------------------------------------------------*/		
	
	function PenList(){
		this.init();
	};
	
	function init(){
		//_root.test += "coucou la penList\n"
		this.flMask = true;
		this.activeList = this.win.box.getPenActiveList();
		this.current= this.win.box.getActivePen();
		super.init();
		this.animList = new AnimList();
		this.display();
	};

	function display(){
	
		for(var i=0; i<_global.penList.length; i++){
			//_root.test+=" - new Pen\n"

			if(!this.activeList[i]){
				this.content.attachMovie("penGFX","pen"+i,i)
				var mc = this.content["pen"+i];
				FEMC.setPColor(mc,0xDDDDDD,0);
				mc.stop();
			}else{
				
				var param ={
					link:"penGFX",
					buttonAction:{
						onPress:	[{obj:this,	method:"selectPen",	args:i}]
					}
				}
				if(i==this.current)param.frameDecal = 5;
				this.content.attachMovie("butCustom","pen"+i,i,param)
				var mc = this.content["pen"+i];
				FEMC.setPColor(mc,0xFFFFFF,100);
				FEMC.setColor(mc.gfx.col,_global.penList[i])
				
			}
			mc._y = 4
			mc._x = 2+i*12			
		}
	}
	
	function selectPen(id){
		if(id == this.current){
			var mc = this.content["pen"+this.current]
			mc.frameDecal=0;
			mc.gfx.gotoAndStop(1)
			this.current = undefined;
		}else{
			var mc = this.content["pen"+id]
			mc.frameDecal=5;
			mc.gfx.gotoAndStop(5)		
			if(this.current!=undefined){
				var mc = this.content["pen"+this.current]
				mc.frameDecal=0;
				mc.gfx.gotoAndStop(1)
			}
			this.current = id;
		}
		
		this.win.box.selectPen(this.current);
	}
	
	function rollOverPen(id){
		var mc = this.content["pen"+id];
		this.animList.addPaint("penColor"+id,mc,FENumber.toColorObj(0xFFFFFF),50)
	}

	function rollOutPen(id){
		var mc = this.content["pen"+id];
		this.animList.addPaint("penColor"+id,mc,FENumber.toColorObj(0xFFFFFF),100)	
	}	
	

//{	
}

























