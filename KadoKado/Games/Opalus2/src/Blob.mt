class Blob extends Phys{//}

	static var RANGE = 1.6
	static var TURN_SPEED = 10
	static var EPAISSEUR = 2
	
	static var FL_SHADE = false;
	
	var vsx:float;
	var vsy:float;
	
	var tsx:float;
	var tsy:float;
	
	var trg:{x:float,y:float}
	
	//var turnList:Array<MovieClip>
	var dec:float;
	var rayCoef:float;
	
	var panel:{>MovieClip,field:TextField,a:float,ta:float};
	var shade:MovieClip;
	
	var dm:DepthManager;
	
	function new(mc){
		super(mc)
		vsx=0
		vsy=0
		
		panel = downcast(Cs.game.gdm.attach("mcCounter",4))
		panel.field.text = string(KKApi.val(Cs.game.turn))
		panel.a = -2.8//-0.77
		panel.ta = panel.a
		
		if(FL_SHADE)shade = downcast(Cs.game.gdm.attach("mcBlob",0));
		
		dm = new DepthManager(root)
		
		rayCoef = 0.5
		

		
	}
	
	function update(){
		
		speedToward(trg,0.1,0.2)
		updateScale();
		updatePanel()
		
		super.update();
		if(FL_SHADE){
			shade._x = root._x;
			shade._y = root._y;
			shade._xscale = root._xscale + EPAISSEUR*2
			shade._yscale = root._yscale + EPAISSEUR*2
		}
	}
	
	function updatePanel(){
		var bpx = x + Math.cos(panel.ta)*root._xscale*rayCoef
		var bpy = y + Math.sin(panel.ta)*root._yscale*rayCoef
		var m = 16
		
		
	
			var rec = 1/0
			var nnta = null
			for(var i=0; i<2; i++ ){
				var sens  = i*2-1
				var nta = panel.ta
				var px = bpx
				var py = bpy
				var tr = 0
				while( px < m || px > Cs.mcw-m || py < m || py > Cs.mch-m ){
					nta+=0.0314*sens
					px = x + Math.cos(nta)*root._xscale*rayCoef
					py = y + Math.sin(nta)*root._yscale*rayCoef
					if(tr++>200)break;
				}
				if(tr<rec){
					rec = tr
					nnta = nta
				}
			}
			if(rec<200)panel.ta = nnta


		
		var da = Cs.hMod(panel.ta-panel.a, 3.14)
		panel.a += da*0.2*Timer.tmod;
			
		panel._x = x + Math.cos(panel.a)*root._xscale*rayCoef
		panel._y = y + Math.sin(panel.a)*root._yscale*rayCoef	

			
			
			
				
	}
	
	function updateScale(){
		var lim = 3
		var c = 0.12
		var dsx = tsx - root._xscale
		vsx += Cs.mm(-lim,dsx*c,lim)
		var dsy = tsy - root._yscale
		vsy += Cs.mm(-lim,dsy*c,lim)
		var fs = Math.pow(0.85,Timer.tmod)
		vsx *= fs
		vsy *= fs
		root._xscale += vsx*Timer.tmod;
		root._yscale += vsy*Timer.tmod;	
		if(root._xscale<0)root._xscale = 0;
		if(root._yscale<0)root._yscale = 0;
		
		var prc = (root._xscale+root._yscale)/2
		if(prc<50){
			panel._xscale = prc*2
			panel._yscale = prc*2
		}
		
	}
	
	function updateSize(){
		var o = Cs.game.zlim
		tsx = ((o.xmax-o.xmin)+RANGE)*Cs.SIZE
		tsy = ((o.ymax-o.ymin)+RANGE)*Cs.SIZE
		
		trg = {
			x:(((o.xmin+o.xmax)*0.5)+0.5)*Cs.SIZE
			y:(((o.ymin+o.ymax)*0.5)+0.5)*Cs.SIZE
		}
		
		// PATCH
		var ox = x;
		var oy = y;
		x = trg.x
		y = trg.y
		var boost = 5
		for( var i=0; i<Cs.game.zone.length; i++ ){
			var p = Cs.game.zone[i]
			var pos = {
				x:p.x*Cs.SIZE,
				y:p.y*Cs.SIZE
			}
			var dist = getDist(pos)
			var a = getAng(pos)

			var dx = Math.cos(a)*tsx*0.5
			var dy = Math.sin(a)*tsy*0.5
			var lim = Math.sqrt( dx*dx + dy*dy )
			while( dist > lim-RANGE*Cs.SIZE ){
				//Log.trace("+++")
				tsx += Math.abs(Math.cos(a)*boost)
				tsy += Math.abs(Math.sin(a)*boost)
				dx = Math.cos(a)*tsx*0.5
				dy = Math.sin(a)*tsy*0.5
				lim = Math.sqrt( dx*dx + dy*dy )			
			}
			
			
			
		}
		x = ox;
		y = oy;

		
	}

//{
}














