class game.Octopus extends Game{//}
	
	var octopus:sp.Phys;
	//var perl:Sprite;
	var perlList:Array<Sprite>;
	var angle:float;
	var rebond:float;
	var cote:float;	
	var m:float;
	var r:int;
	var encre:MovieClip;
	var bulle:MovieClip;
	var distance:float;
	var a:float;
	var b:float;
	var fieldText:TextField;
	var timer:float;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 400;
		super.init()
		perlList=new Array ();
		rebond = -0.5;
		r=15;
		var c=dif/100;
		m=r+40*(1-c);
		timer=35;

		
		attachElements();
	};
	
	function attachElements(){
		
		octopus=newPhys("mcOcto")
		octopus.x=120;
		octopus.y=40;
		octopus.weight=0.15;
		octopus.skin.stop();
		octopus.init();
	
		perlList=new Array ();
		var x=2+dif*0.1
		

		
		
		
		for(var i=0;i<x;i++){
			// CREE LA PERLE
			var perl=newSprite("mcPerl");
			
			// PLACE LA PERLE
			while(true){
				perl.x=m+Std.random(int(Cs.mcw-2*m));
				perl.y=Std.random(190)+30;
				var flbreak=true
				for(var u=0; u<perlList.length; u++){
					var perl2 = perlList[u]
					a=perl2.x-perl.x;
					b=perl2.y-perl.y;
					distance=Math.sqrt(a*a+b*b)
					if(distance<30){
						flbreak=false	
					}
					
				}
				if(flbreak){
					break
				}
			}
			
			// INITIALISE LA PERLE
			perl.init()
			
			// ENREGISTRE LA PERLE
			perlList.push(perl);
			
		}			
	}
	
	function update(){
		if(timer<35){
			timer=timer+1
			}
// 		fieldText.text=string(dif);
		var skin=downcast(octopus.skin)
		
		if(octopus.y>200){
			octopus.y=200
			octopus.vity*=rebond
			if(octopus.vity<-1 ){
				skin.eye.play()
			}
			
		}
		if(octopus.y<20){
			octopus.y=20
			octopus.vity*=rebond
			if(octopus.vity>1){
				skin.eye.play()
			}
		}
		if(octopus.x<20){
			octopus.x=20
			octopus.vitx*=rebond
			if(octopus.vitx>1){
				skin.eye.play()
			}
		}
		if(octopus.x>220){
			octopus.x=220
			octopus.vitx*=rebond
			if(octopus.vitx<-1){
				skin.eye.play()
			}
		}
		
		octopus.skin._rotation = (this._xmouse/240)*180-180
		
	
		
		for(var i=0;i<perlList.length; i++){
			var perl = perlList[i]
			var dx=octopus.x-perl.x;
			var dy=octopus.y-perl.y;
			cote=Math.sqrt(dx*dx+dy*dy)
			
			
			
				
			if(cote<30){
				
				bulle=dm.attach("mcBulle",Game.DP_SPRITE);
				bulle._x=perl.x;
				bulle._y=perl.y;
				perl.kill();
				perlList.splice(i,1);
				i--;
				
			}
			
			
			
			
			if(perlList.length==0){
				setWin(true)
			}
		}			
			
			
		
		
		
		
		
		super.update();
	}
	
	function click(){
		
		if(timer==35){
			encre=dm.attach("mcEncreAnim",Game.DP_SPRITE)
			encre._xscale=120
			encre._yscale=120
			encre._x=octopus.skin._x
			encre._y=octopus.skin._y
			encre._rotation=octopus.skin._rotation
			angle=octopus.skin._rotation*(3.14/180)
			octopus.vitx += Math.cos(angle)*10
			octopus.vity += Math.sin(angle)*10
			octopus.skin.play()
			encre.play()
				
			dm.over(octopus.skin)
			timer=0			
		}
		

				
	}
		
		
		
		
	
	
//{	
}

