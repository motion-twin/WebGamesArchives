class cp.WheelMng extends Component{//}

	var flWheel:Boolean;
	var flSwap:Boolean;
	//var timer:Number;
	//var dayCoef:Number;
	
	
	var dp:Number;
	var ray:Number;
	var turning:Number;
	var accel:Number;
	
	
	var animList:AnimList;
	var inside:MovieClip;
	var now:Date;
	
	var list:Array;
	var currentPos:Number;
	
	var bar:MainBar;
	
	function WheelMng(){
		this.init();
	}
	
	function init(){
		
		this.fix = {w:186,h:64}
		
		super.init()
		
		//_root.test+="[cp.WheelMng] init()\n"
		//this.now = _global.servTime.getDateObject()//new Date();
		this.flWheel = false;
		this.flSwap = false;
		this.ray = 100;
		this.dp = 0;
		this.animList = new AnimList();
		this.currentPos = 0;
		this.turning=0;
		
		if(this.list==undefined)this.list=["whDayNight","whFruitMonth"];
		
		this.swapWheel()
		
	}
	
	function swapWheel(){
		
		this.currentPos = (this.currentPos+1)%this.list.length;
		this.loadWheel(this.list[this.currentPos])
	}
		
	function loadWheel(link){
		
		this.dp++
		this.inside.attachMovie(link,"wheel"+this.dp,10000-this.dp,{mng:this});
		var mc = this.inside["wheel"+this.dp];
				
		
		if(this.flWheel){
			//_root.test+="thisWay(2)!\n"
			this.turning = 2	//1
			this.accel = 0.3	//0.3
			this.animList.addAnim("rotateWheel",setInterval(this,"animDisk",25,mc,this.inside["wheel"+(this.dp-1)]))
			this.flSwap = true;
		}else{
			//_root.test+="thisWay(2)!\n"
			mc._x = -this.ray*2;
			mc.pos = {x:0,y:0};
			this.animList.addSlide("animWheel"+this.dp,mc);	
		}
				
		this.flWheel = true;
		
	}	

	function removeWheel(){
				
		var mc = this.inside["wheel"+this.dp];
		mc.pos = {x:0,y:-this.ray}
		this.animList.addSlide("animWheel"+this.dp,mc,{obj:mc,method:"kill"})
		
		this.flWheel = false;
		
	}
	
	function animDisk(mcIn,mcOut){
		
		// Effet a refaire
		
		this.accel -= _global.tmod/90;
		var coef = Math.pow((1+this.accel),_global.tmod)
		this.turning*=coef;
		
		this.inside._rotation = this.turning*6
		this.inside["wheel"+this.dp].onBaseTurn();
		
		if(coef<1){
			if(mcOut._visible)this.turning*=-1;
			mcOut.kill();
			
		}else{
			mcOut._alpha = (coef-1)*400
		}

		if(Math.abs(this.turning)<0.1){
			this.animList.remove("rotateWheel");
			this.turning=0;
			this.flSwap = false;
		}
		
	}
		
	function pressSwap(){
		//_root.test+="this.flSwap("+this.flSwap+")\n"
		if(!this.flSwap)this.swapWheel();
	}
	
	function pressValidate(){
		this.bar.toggleHalfHide();
	}	
	
	function pressLeft(){
	
	}
	
	function pressRight(){
	
	}	
//{
}
















