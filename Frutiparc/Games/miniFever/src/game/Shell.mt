class game.Shell extends Game{//}
	

	var front:Sprite;
	var shellFish:MovieClip;
	var shell:Sprite
	var time:float;
	var algue:Sprite;
	var flClose:bool;
	var attend:float;
	var fishList:Array<{>MovieClip,vitx:float}>
	var behavior:float;
	
	var trapped:MovieClip;
	
	function new(){
		
		super();
	}

	function init(){
		gameTime = 320;
		super.init();
		attachElements();
		time = 0;
		flClose = false;
		attend = 10;
		behavior = Std.random(3);
		
	};
	
	function attachElements(){
		
			
		front = newSprite("mcFront");
		front.x = 0;
		front.y = 0;
		front.init();
		
		shell = newSprite("mcShell");
		shell.x = 108;
		shell.y = 130;
		shell.init();
		trapped = downcast(shell.skin).trapped
		trapped._visible = false;
		
		shell.skin._xscale = 70;
		shell.skin._yscale = 70;
		
		shellFish = dm.attach("mcShellFish",Game.DP_SPRITE);
		shellFish._x = -40;
		shellFish._y = 180;
		shellFish._xscale = 70;
		shellFish._yscale = 70;

		
		algue = newSprite("mcAlgue");
		algue.x = 29;
		algue.y = 180;
		algue.init();
		
		
		fishList=new Array();
		for(var i=0; i<20;i++){
			genRandomFish();
							
		}
		
		

	
	}
	
	function update(){
		
		var gen = Std.random(10);
		if( gen == 0){
			genBgFish();
		}
		moveBgFish();
		
		time += 1
		var speed = 2.08+dif*0.25
		if(dif>50){
			
			if(behavior == 0){
				if(shellFish._x>50 && shellFish._x<80){
					speed *= 0.3	
				}
			}
		}
		if(time>50){
			shellFish._x=shellFish._x+speed
		}
		
		
		if(shellFish._x>Cs.mcw){
			setWin(false)
		}
		
		switch(step){
			case 1 :			
				if (base.flPress){
					shell.skin.gotoAndPlay("1")
					step=2	
					for(var i=0; i<10; i++ ){
						var p = newPart("mcBubble");
						p.x=194-Std.random(20);
						p.y=185;
						p.vity = -4-Std.random(8)
						p.timer = 10+Std.random(20)
						p.scale = 20+Std.random(80)
						p.flPhys = false;
						p.init();
					}
					if ( shellFish._x>shell.x && shellFish._x<shell.x+shell.skin._width ){
						shellFish.removeMovieClip()
						trapped._visible=true
						setWin(true)
					}
					else {
						setWin(false)
					}
				
					
				}
				break;
			case 2 :
				
				break;
			
			
		}

		super.update();
	}	
		
	function genBgFish(){
		var sardine = downcast(dm.attach("mcSardine", Game.DP_SPRITE));
		var sens = Std.random(2);
		var taille = Std.random(100)+1;
		sardine._x = -20+sens*280;
		sardine._y = Std.random(200);
		sardine._xscale = taille*(sens*2-1);
		sardine._yscale = taille;
		sardine.vitx=-((sens*2-1)*(taille/20));
		fishList.push(sardine)
		dm.under(sardine)
	}
	
	function genRandomFish(){
		var sardine = downcast(dm.attach("mcSardine", Game.DP_SPRITE));
		var sens = Std.random(2);
		var taille = Std.random(100)+1;
		sardine._x = Std.random(240);
		sardine._y = Std.random(200);
		sardine._xscale = taille*(sens*2-1);
		sardine._yscale = taille;
		sardine.vitx=-((sens*2-1)*(taille/20));
		fishList.push(sardine)
		dm.under(sardine)
	}
	
	function moveBgFish(){
		for(var i=0;i<fishList.length; i++){
			var sardine = fishList[i]
			sardine._x = sardine._x+sardine.vitx
			var margin = 20
			if ( (sardine._x<-margin && sardine.vitx<0 ) || ( sardine._x>Cs.mcw+margin && sardine.vitx>0 ) ){
				sardine.removeMovieClip();
				fishList.splice(i,1);
				i--;
			}			
			
			
		}
		
		
	}
		
		
		/*time=time+1
		//Log.trace(time)
		if (time>50){
			shellFish._x=shellFish._x+5
		}
		if(shellFish._x>150){
			setWin(false)
		}			
			
		
		//
		super.update();
	}
	
	function click(){
	
		
		}
		
		/*
		if ( flClose==false ){
			shell.skin.gotoAndPlay("1")
			flClose = true
		
			for(var i=0; i<10; i++ ){
				var p = newPart("mcBubble");
				p.x=194-Std.random(20);
				p.y=185;
				p.vity = -4-Std.random(8)
				p.timer = 10+Std.random(20)
				p.scale = 20+Std.random(80)
				p.flPhys = false;
				p.init();
			}
			if( 90<shellFish._x && shellFish._x<150 ){
			shellFish.removeMovieClip()
			setWin(true)
			}
			
		}
		//*/
				

			
		
		
		
			
//{	

}


