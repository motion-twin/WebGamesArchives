class ac.Graveyard extends Action{//}

	var data:DataGraveyard;
	var pl:Player;
	var card:Card;
	var pList:Array<Part>
	
	function new(d){
		super(d)
		data = downcast(d)
	}
	
	function init(){
		super.init();
		
		card = Card.getCard( data.$inst );
		pl = Cs.game.getPlayer( data.$pid );
		
		// Log.trace("graveyard:"+data.$inst)
		switch(card.data.$type){
			case 0: // DINOZ
				card.enchants = []
				pl.dinoz.remove(card)
				//pl.orderDinoz(1);
				break;
			
			case 1: // OBJECT
				pl.objects.remove(card)
				pl.updateAllPos()
				break;
			
			case 2: // ENCHANT
				break;

			case 3: // INCANTATION
				break;
		}
		
		//
		card.disenchant();
		/*
		if(card.enchantTarget!=null ){
			card.enchantTarget.enchants.remove(card)
		}
		*/
		//
		card.removeAllToken();
		
		
		// MOVE
		if( data.$token==0 ){
			var tx = pl.graveyard.x
			var ty = pl.graveyard.y + pl.graveyard.card.y
			card.goto( tx, ty, 70);
			card.flipIn();
			Cs.log( card.getName()+" part au cimetière", 1 )
		}else{

			pList = []
			var w = Card.WW*card.scale/100
			var h = Card.HH*card.scale/100
			var bmp = new flash.display.BitmapData(Card.WW,Card.HH,true,0xFFFF0000)
			var m = new flash.geom.Matrix()
			m.translate(Card.WW*0.5,Card.HH*0.5)
			bmp.draw(card.root,m,null,null,null,null)
			
			var max = 12
			for( var i=0; i<max; i++ ){
								
				var mc = Cs.game.dm.empty(Game.DP_PART)
				var pdm = new DepthManager(mc)
				var base = pdm.empty(0)
				var mask = pdm.attach("mcAngle",0)
				mask._rotation = i/max * 360
				mask._xscale = card.scale
				mask._yscale = card.scale
				base.attachBitmap(bmp,0)
				base._x = -w*0.5
				base._y = -h*0.5
				base._xscale = card.scale
				base._yscale = card.scale
				base.setMask(mask)
				
				var p = new Part(mc)
				p.x = card.x
				p.y = card.y
				var a = i/max * 6.28
				var sp = 1 + Math.random()*2
				p.vx = Math.cos(a)*sp
				p.vy = Math.sin(a)*sp
				p.timer = 20+Math.random()*10
				pList.push(p)
				
				Cs.glow(p.root,3,2,0x000000)
				
			}
			card.kill();
			waitTimer = 8
			
		}
		
	}
	
	function update(){
		super.update();
		if(data.$token==0){
			if(card.trg==null){
				pl.graveyard.putCard(card);
				kill();
			}
		}

	}



//{
}