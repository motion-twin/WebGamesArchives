class inter.Wheel extends Inter{//}

	static var RAY = 42
	
	
	var depthRun:int;
	var count:float;
	var speed:float;
	
	var fList:Array<{>MovieClip}>
	var prize:int;
	var flameMax:int
	var dm:DepthManager;
	
	var wheel:MovieClip;
	
	function new(b){
		width = 80
		height = 80
		depthRun = 0;
		flameMax = 12;
		speed = 0.05
		fList = new Array();
		super(b);
	}
	
	function init(){
		link = "interWheel";
		super.init();
		dm = new DepthManager(skin)
		wheel = downcast(skin).wheel
	}
	
	function update(){
		super.update();
		//count -= count.tmod*speed
		if( count/100 > fList.length/flameMax ){
			addFlame();
		}
		if( count/100 <= (fList.length-1)/flameMax ){
			popFlame();
		}		
	}
	
	function addFlame(){
		var mc = dm.attach("mcFlame",2)
		var a = (1-(fList.length/flameMax))*6.28 - 1.57;
		mc._x = wheel._x + Math.cos(a)*RAY;
		mc._y = wheel._y + Math.sin(a)*RAY;
		fList.push(mc)
	}
	
	function popFlame(){
		//Manager.log("pop!")
		var mc = fList.pop(); 
		dm.over(mc)
		mc.play();

	}
	
	function setPrize(n){
		prize = n;
		var it = Item.newIt(n)
		var pic = it.getPic(dm,1)
		pic._x = wheel._x
		pic._y = wheel._y
		pic._xscale = 40
		pic._yscale = 40
	}
	
	function incCount(inc){
		count = Cs.mm(0,count+inc,100)
	}
	
	function setCount(t){
		count = Cs.mm(0,t,100)
	}
	

	
	
	
	
	
	
	
	
//{	
}