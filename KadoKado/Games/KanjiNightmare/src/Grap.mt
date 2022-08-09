class Grap extends Sprite{//}
	


	var flMain:bool;
	var flFly:bool;
	
	var long:float;
	var vx:float;
	var vy:float;
	var speed:int;
	
	function new(mc){
		super(mc);
		
		flMain = true;
		flFly = true;

	}
	
	
	function update(){
		
		super.update();

		if(flFly){
				
			/*
			if( y<0 || !Cs.game.isFree(int(x),int(y)) ){
				var vvx = vx*Timer.tmod;
				var vvy = vy*Timer.tmod;
				x -= vvx;
				y -= vvy;
				
				var max = 40;
				for( var i=0; i<max; i++){
					var c = (i+1)/max
					var px = x + c*vvx;
					var py = y + c*vvy;
					if( py>0 && !Cs.game.isFree(int(px),int(py)) ){
						x = px;
						y = py;
						break;
					}
				}
				vx = 0
				vy = 0
				flFly = false;
				
				var a = Math.atan2(vvy,vvx);
				var ray = 12;
				x -= Math.cos(a)*ray;
				y -= Math.sin(a)*ray;
				root.gotoAndStop(string(2));
				
				updatePos();
				

			}
			*/
			for( var i=0; i<speed; i++ ){
				
				var oy = y
				
				x += vx*Timer.tmod;
				y += vy*Timer.tmod;
				
				var flCol = y<10;
				
				for( var n=0; n<Cs.game.platList.length; n++){
					var pl = Cs.game.platList[n];
					if(pl.y+12<oy && pl.y+12>y && x>pl.x && x<pl.x+pl.w ){
						flCol = true;
						pl.grap = this;
						break;
					}
				}
				
				//if( !Cs.game.isFree(int(x),int(y)) )
				if( flCol ){
					flFly = false;
					
					var a = Math.atan2(vy,vx);
					var ray = 12;
					x -= Math.cos(a)*ray;
					y -= Math.sin(a)*ray;
					root.gotoAndStop(string(2));
					//long = GP_DIST;//getDist(Cs.game.hero)*0.5
					
					if( flMain )Cs.game.hero.grap();
					
					updatePos();
				
				}
			
			}
			
			if(y<0){
				if(flMain){
					Cs.game.hero.releaseGrap();
				}
				kill();
			}
				
				
		}else{
			if(!flMain){
				/*
				var m = new flash.geom.Matrix();
				m.scale(root._xscale/100,root._yscale/100);
				m.rotate(root._rotation*0.0174);
				m.translate(x,y);
				Cs.game.mcCaveTop.bmp.draw(root,m,null,null,null,null);		
				*/
				kill();
			}
		}
		
	}
	
	function orient(){
		var sens = 1
		if(vx<0) sens = -1
		root._xscale = sens*100
		root._rotation = Math.atan2(vy,vx)/0.0174 
		if(vx<0)root._rotation += 180	
	}
		
	function drop(){
		flMain = false;
	}
	
//{
}