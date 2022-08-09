class Medic extends Ally{//}
	
	static var HEAL_RANGE = 6
	static var SEEK_RANGE = 60
	static var HEAL_RATE = 0.15
	
	function new(mc){
		type = 2
		super(mc)
		
		va = 1;
		ca = 0.3;
		ray = 8;
		tol = 6;
		
		hpMax = 10;
		frame = 0;
	
		accel = 0.2
		speedMax = 3
		
		
	
		damage = 6;
		rate = 4
		
	}
	
	function update(){
		super.update();
		
		if(wp==null){
			updateHeal();
		}

	
		
	}
	
	function updateHeal(){
			var list = new Array();
			for( var i=0; i<Cs.game.aList.length; i++ ){
				var sp = Cs.game.aList[i]
				if(sp!=this && sp.type!=3 &&sp.hp<sp.hpMax ){
					var dist = getDist(sp)
					if(dist<sp.ray+ray+SEEK_RANGE)list.push({sp:sp,dist:dist});
				}
			}	
			
			var f = fun(a,b){
				if(a.dist>b.dist)return 1;
				return -1;
			}
			list.sort(f)
			
			for( var i=0; i<list.length; i++ ){
				var o = list[i]
				var sp = o.sp
				if(cd<0 ){
					if( o.dist<sp.ray+ray+HEAL_RANGE ){
						for(var n=0; n<3; n++)towardAngle(getAng(sp));
						cd = rate
						sp.hp = Math.min(sp.hp+HEAL_RATE,sp.hpMax)
						sp.showLife();
						sp.lifePanelTimer = 30
						skin.gotoAndPlay("heal")
						frame = null
						for( var n=0; n<1; n++ ){
							var p = new Part(Cs.game.dm.attach("partLuciole",Game.DP_PART))
							p.x = sp.x+(Math.random()*2-1)*sp.ray;
							p.y = sp.y+(Math.random()*2-1)*sp.ray;
							p.setScale(50+Math.random()*100)
							p.fadeType = 0
							p.timer = 10+Math.random()*10
						}
						return;
					}else{
						var d = o.dist-(sp.ray+ray)
						var a = getAng(sp)
						var wp = {
							x:x+Math.cos(a)*d
							y:y+Math.sin(a)*d
							ray:null
						}
						setWaypoint(wp)
						
						
						return;
					}
				}
			}		
	}
	

	function findTrg(){
		return null;
	}

	
	function attack(trg){
		return;
	}
	

//{
}



