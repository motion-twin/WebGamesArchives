class Menu extends Slot{//}

	var step:int;
	var menuId:int;
	var decal:float;
	var baseName:String;
	//var bList:Array< { x:float, y:float ,vx:float, vy:float, vs:float, vd:float, vr:float, sc:float, sp:Sprite, dec:float, ray:float, shade:MovieClip } >
	var bList:Array< sp.Bubble >
	
	var mList:Array< MovieClip >
	var dList:Array< MovieClip >
	
	var infoList:Array<int>
		
	var title:{mc:MovieClip,vs:float};
	
	
	
	function new(){
		super();
	}
	
	function init(){
		super.init();
		
		mList= new Array();
		dList= new Array();
		
		initStep(0)
	}
	
	function initStep(n){
		step = n;
		switch(step){
			case 0:
				
				var mc = dm.attach("menuTitle",10)
				mc._x = Cs.mcw*0.5
				mc._y = Cs.mch*0.5
				mc._xscale = 0
				mc._yscale = 0
				title = {mc:mc,vs:0}
				//return;
				bList= new Array();
				for( var i=0; i<20; i++ ){
					var sp = new sp.Bubble();
					sp.setSkin( dm.attach( "menuBubble", 10 ) )
					sp.tx = (Math.random()-0.5)*Cs.mcw
					sp.ty = (Math.random()-0.5)*40
					sp.sc = 10+Std.random(20)
					sp.x = title.mc._x
					sp.y = title.mc._y
					if(i==10)dm.over(title.mc);
					sp.skin._xscale = 1
					sp.skin._yscale = 1
					sp.skin.gotoAndStop("1")
					//sp.init();
					var shade = dm.attach("menuBubble",9)
					shade.gotoAndStop("2")
					sp.setShade(shade,6)
					sp.setTrg(title.mc)
					sp.vx = (Math.random()*2-1)*10
					sp.vy = (Math.random()*2-1)*10
					sp.init();
					sp.list= bList;
					bList.push(sp)
				}
			
				break;
			case 1:	// TITLE 2
				menuId = 0
				decal = 0;
				break;
			case 2:	// NEW MENU
				destroyMenu();
				switch(menuId){
					case 0:

					
						newMenu(1);
						newMenu(2);
						newMenu(3);
						newMenu(4);
						newMenu(5);
						break;
					case 1:
						/*
						newMenu(10)
						newMenu(11)
						newMenu(12)
						newMenu(13)
						*/
						for( var i=0; i<5; i++ ){
							var mc = newMenu(i+10)
							if( Cm.card.$arcade[i] == null ){
								mc.onPress = null
								mc.useHandCursor = false;
								mc._alpha = 50
							}
						}					
				}
				initMenu();
				break				
		}
		
	}
	
	function update(){
		super.update();
		moveBubble();
		switch(step){
			case 0:
				// TITLE
				var ds = 100 - title.mc._xscale
				var lim = 6
				title.vs += Math.min(Math.max(-lim,ds*0.3),lim)*Timer.tmod
				title.vs *=Math.pow(0.8,Timer.tmod)
				title.mc._xscale += title.vs*Timer.tmod
				title.mc._yscale = title.mc._xscale
				if(Math.abs(ds)+Math.abs(title.vs)<1)initStep(1);
				break;
			case 1: // TITLE 2
				var lim = 628*0.75
				decal = Math.min(decal+10*Timer.tmod,lim)
				title.mc._y = 40+(1+Math.sin(decal/100))*(Cs.mch-80)*0.5
				if(decal==lim)initStep(2);
				break;
				
			case 2:	// MENU
				for( var i=0; i<mList.length; i++ ){
					var menu = mList[i]
					var dx = Cs.mcw*0.5 - menu._x
					menu._x += dx*0.2*Timer.tmod;
				}
				for( var i=0; i<dList.length; i++ ){
					var menu = dList[i]
					menu._xscale *= 0.7;
					menu._yscale = menu._xscale;
					if(menu._xscale<1){
						dList.splice(i--,1)
						menu.removeMovieClip()
					}
				}
				if( mList.length ==0 && dList.length == 0){
					var dy = -100 - title.mc._y
					title.mc._y += dy*0.2*Timer.tmod;
					if( Math.abs(dy) < 1 ){
						Manager.genSlot(baseName)
						Manager.slot.infoList = infoList;
						Manager.slot.init();
					}
					
				}
				
				
				break
		}		
	}
	
	function newMenu(id){
		var mc = dm.attach("mcMenuSlot",10)
		var me = this;
		mc.onPress = fun(){
			me.select(id)
		}
		mList.push(mc)
		mc.gotoAndStop(string(id))		
		return mc;
	}
	
	function initMenu(){
		var max = mList.length;
		var mt = 56
		var mb = 2
		var ec  = (Cs.mch-(mt+mb))/(max+1)
		for( var i=0; i<max; i++ ){
			var mc = mList[i];
			mc._x = Cs.mcw*0.5 + ((i%2)*2-1)*200;
			mc._y = mt+(i+1)*ec;
		}
	}
	
	function select(id:int){
		//Log.trace(menuId+","+id)
		switch(menuId){
			case 0:	// MAIN
				switch(id){
					case 1:	// > ARCADE
						menuId = 1
						break;
					case 2:	// > FEVER
						menuId = null
						baseName = "baseFever"
						break;
					case 3:	// > TIME
						menuId = null
						baseName = "baseChrono"
						break;
					case 4:	// > TRAIN
						menuId = null
						baseName = "baseTrain"					
						break;
					case 5:	// > SECRET
						break;	
					case 6:	// > OPTION
						break;					
				}			
				break;
			case 1 : // ARCADE
				menuId = null
				baseName = "baseArcade"
				infoList = [id-10]
				break;				
		}
		initStep(2)
		
		
	};
		
	function moveBubble(){
		for( var i=0; i<bList.length; i++ ){
			var sp = bList[i];
								
			if(Std.random(800)==0){
				sp.tx = (Math.random()-0.5)*Cs.mcw
				sp.ty = (Math.random()-0.5)*40
				sp.sc = 10+Std.random(20)
				sp.vd = 10+Math.random()*20
				sp.ray = 5+Math.random()*10
			}
			
			sp.update();
			
			
			
		}	
	}
	
	function destroyMenu(){
		while(mList.length>0){
			var menu = mList.pop();
			menu.onPress = null;
			dList.push(menu);
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
//{	
}