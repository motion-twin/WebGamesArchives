class sp.el.Eye extends sp.Element{//}

	static var BALL_SPEED = 40
	
	var dist:float;
	var ang:float;
	var color:int;
	var light:int;
	

	var ray:sp.Part;
	var ball:sp.Part;
	var center:MovieClip;
	
	function new(){
		et = Cs.E_EYE;
		link = "eye";
		super();
	}

	function init(){
		super.init();
		color = Cs.game.getColor();
		Mc.setColor( downcast(skin).col, Cs.colorList[color] )

		center = downcast(skin).center
		light = 0
		updateLight()
		

		
	}


	function update(){
		super.update();
	}
	
	function initActiveStep(){
		if( light > 1 ){
			var tx = Std.random(Cs.game.xMax)
			var ty = 0
			var tr = 0
			while( !Cs.game.isFree(tx,ty) ){
				tr++;
				tx = Std.random(Cs.game.xMax)
				if(tr>20)ty++;
				if(tr>100)return;
			}
			
			
			var t:sp.el.Token = downcast( Cs.game.genElement( 0, tx, ty, 1 ) )
			t.setType(color)
			dist = getDist(t)
			ang = getAng(t)
	
			addToList(Cs.game.activeElementList)
			light = 0
		}else{
			light++
			
		}
		updateLight();
		

	}
	
	function activeUpdate(){
		if(ray==null){
			initEffect();
		}
		
		ray.skin._yscale *= 0.8
		ray.skin._xscale += BALL_SPEED
		
		
		if( ball.y  < -60 ){
			Cs.game.activeElementList.remove(this)
			ray.kill()
			ray = null;
			
		}
	}
	
	function updateLight(){
		center._xscale = center._yscale = 20 + light*40
	}
	
	function initEffect(){
		
		// RAY
		ray = Cs.game.newPart("partSlash",null)
		ray.x = x+Cs.game.ts*0.5
		ray.y = y+Cs.game.ts*0.5
		ray.init();
		ray.skin._xscale = 0//dist;
		ray.skin._rotation = ang/0.0174
	
		// BALL
		ball = Cs.game.newPart("partEyeBall",null)
		ball.x = x+Cs.game.ts*0.5
		ball.y = y+Cs.game.ts*0.5
		ball.vitx = Math.cos(ang)*BALL_SPEED
		ball.vity = Math.sin(ang)*BALL_SPEED
		ball.friction = 1
		ball.init();
		ball.orient();
		Mc.setColor(downcast(ball.skin).col, Cs.colorList[color])
		
		
		// RADIAL RAY
		for( var i=0; i<12; i++ ){
			var p = Cs.game.newPart( "partRay", Game.DP_PART2 )
			p.x = ray.x;
			p.y = ray.y;
			p.vitr = (Math.random()*2-1)*10
			p.fadeTypeList = [4]
			p.timer = 15+Math.random()*10
			p.init();
			p.skin._rotation = Math.random()*360
			p.skin._xscale = 4+Math.random()*50
		}
		
	}
	
	function blast(){
		super.blast();
		explode();
		kill()
		
	}
	
	function explode(){
		// ONDE
		var po = Cs.game.newPart("partLightCircle",null);
		po.x = x+Cs.game.ts*0.5
		po.y = y+Cs.game.ts*0.5
		po.vits = 50
		po.scale = 20
		po.fadeTypeList = [1]
		po.timer= 8
		po.init();
		
		// PART
		for( var i=0; i<12; i++ ){
			var sp = Cs.game.newPart("partElementCrystalDark",null);
			sp.x = x+Cs.game.ts*0.5
			sp.y = y+Cs.game.ts*0.5
			var a = Math.random()*6.28
			var p = 1+Math.random()*5
			sp.vitx = Math.cos(a)*p
			sp.vity = Math.sin(a)*p
			sp.vitr = (Math.random()*2-1)*10
			sp.timer = 8+Math.random()*12
			sp.scale = 30+Math.random()*30
			sp.init();
			sp.skin._rotation = Math.random()*360

			//var token:sp.el.Token = downcast(e)
			Mc.setColor(sp.skin, Cs.colorList[color])
			Mc.modColor(sp.skin, 1, 60)

		}	
	}

	
	// LUZ



	

	
//{	
}