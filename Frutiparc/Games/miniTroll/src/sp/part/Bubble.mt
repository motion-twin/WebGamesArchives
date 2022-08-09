class sp.part.Bubble extends sp.Part{//}

	var flDeath:bool;
	
	var decal:float;
	var ray:float;
	var life:float;
	
	var trg:{x:float,y:float}
	
	var fountain:base.Fountain;
	
	var faerie:sp.pe.Faerie
	var b:MovieClip;
	
	var vd:float;
	
	
	function new(){
		super();
		decal = 0;
		ray = 10;
		life  = 5;
		vd = 10;
		flDeath  = false;
		
		fountain = Std.cast(Cs.base)
		
	}	
	
	function init(){
		b = Std.attachMC(skin,"mcFaerieBubble",2)
		
	}
	
	function update(){
		
		var dif = 10 - vd
		vd += dif*0.1*Timer.tmod;
		decal = (decal+vd*Timer.tmod)%628
		
		b._xscale = 100 + Math.cos(decal/100)*10
		b._yscale = 100 + Math.sin(decal/100)*10
		
		if( trg == null ) getTrg();

		
		towardSpeed(trg,0.02,0.05)

		if( getDist(trg) < 5 ){
			trg = null;
		} 		

		
		checkBounds();
		
		super.update();
		
		
	}
	
	function checkBounds(){
		if( x<ray || x>Cs.game.width-ray ){
			x = Cs.mm(ray,x,Cs.game.width-ray)
			vd*=1.5;
			vitx *= -1
		}
		if( y<ray || y>Cs.game.height-ray ){
			y = Cs.mm(ray,y,Cs.game.height-ray)
			vd*=1.5;
			vity *= -1
		}
	}
	
	function setFaerieInfo(fi){
		var sp = new sp.pe.Cursor()
		sp.setInfo(fi)
		sp.init();	
		sp.birth(Std.createEmptyMC(skin,1))
		sp.skin._xscale = sp.skin._yscale = 80 
		sp.body.body.stop();
		faerie = sp;
		
		
	}
	
	function getTrg(){
		var m = 20
		trg = {
			x:m+Math.random()*(Cs.mcw-2*m)
			y:m+Math.random()*(Cs.mch-2*m)
		}
	}	
	
	function harm(damage){
		vd = 40
		life--;
		Cs.base.flash();
		
		if( life == 0 ){
			fountain.freeFaerie();
			kill();
		}
		
				
		//skin._alpha = 50;
	}
	
	
//{
}