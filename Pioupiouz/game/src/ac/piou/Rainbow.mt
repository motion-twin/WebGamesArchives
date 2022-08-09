class ac.piou.Rainbow extends ac.Piou{//}

	static var CENTER = 50
	static var HEIGHT = 50
	
	var flWillExplode:bool;
	
	var pList:Array<Array<float>>;
	
	var list:Array<MovieClip>;
	
	var ox:float;
	var oy:float;
	var sens:int;
	var explodeTimer:float;
	
	var star:Part;
	
	function new(x,y){
		super(x,y)
		pList = new Array();
	}
	
	function init(){
		super.init();
		piou.root.gotoAndStop("freeze")
		star = Cs.game.newPart("mcRainbowStar");
		star.x = piou.x + 3*piou.sens
		star.y = piou.y + 8
		star.vx = 5*piou.sens
		star.vy = -5
		star.weight = 0.25
		star.vr = 7
		star.frict = 1
		ox = star.x;
		oy = star.y;
		timer = 4
		sens = piou.sens
		list = new Array();
	}
	
	function update(){
	
		super.update();
		
		
		if(star!=null){
			var mc = attachBuilder("mcRainbow",star.x,star.y,false).smc
			var dx = ox - star.x;
			var dy = oy - star.y;
			mc._rotation = Math.atan2(dy,dx)/0.0174
			mc._xscale = Math.sqrt(dx*dx+dy*dy)+1
			mc._yscale *= sens*gs
			list.push(mc)
			mc.stop();
		}
		
		for( var i=0; i<list.length; i++ ){
			var mc = list[i]
			mc.nextFrame();
			if(mc._currentframe==mc._totalframes){
				traceMeUnder(mc._parent)
				list.splice(i--,1)
			}
		}
		
		ox = star.x;
		oy = star.y;
		pList.push([ox,oy])
		if(pList.length>40)pList.shift();
		

		
		

		
		if(star!=null){
			star.updatePos();
			if(flWillExplode){
				starExplode();
				star.kill();
				star = null
			}
		}
		
		if(timer == null){
			if(!Level.isSquareFree(star.x,star.y,1) || star.isOut(20) ){
				flWillExplode = true;
				
			}
		}else{
			if(timer<0){
				timer = null
				go();
			}
		}
		
		if( Math.random() < 0.5 ){
			var p = Cs.game.newPart("partLightRainbow")
			var index = Std.random(pList.length)
			var pos = pList[index]
			pList.splice(index,1)
			p.x = pos[0]
			p.y = pos[1]+6
			p.weight = 0.1+Math.random()*0.25
			p.timer = 15+Math.random()*10
			p.fadeType = 0;
			//p.bouncer = new Bouncer(p)
		}
		
		if(star==null && list.length==0){
			kill();
		}
	}
	
	function starExplode(){
		var max = 20;
		for( var i=0; i<max; i++ ){
			var a = i/max * 6.28
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var p = Cs.game.newPart("partLightRainbow")
			var dist = 4+Math.random()*6
			p.x = star.x+ca*dist;
			p.y = star.y+sa*dist;
			p.vx = ca*dist*0.2
			p.vy = sa*dist*0.2
			p.fadeType = 0;
			p.timer = 10+Math.random()*10
		}
	}
	
	function interrupt(){
	
	}

	function onReverse(){
		super.onReverse();
		oy = Cs.gry(oy)
		star.vy*=-1
	}
	
//{
}
