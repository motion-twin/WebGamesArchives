class Cm{//}

	static var TRAIN_LIMIT = 	200
	static var TRAIN_PRIZE_LIMIT = 	50
	static var CHRONO_LIMIT =	5*60000
	static var CHRONO_TOP_LIMIT =	4*60000
	static var POTIONS_DIF_LIST =	[20,50,75,90,100]
	
	static var VERSION = 0.1
	
	static var card:Card;
	static var pref:Pref;
	static var so:SharedObject
	
	
	// GENERAL
	
	static function loadFruticard(){
		var fc = null;
		if( Client.STANDALONE ){
			so = SharedObject.getLocal("miniFever/card");
			fc = downcast(so.data).fruticard;
			if(fc == null){
				fc = new Array();
				downcast(so.data).fruticard = fc;
			}
			
		}else{
			fc = Manager.client.slots;
		}
			
		
		card = downcast(fc[0])
		pref = downcast(fc[1])
		
		var flForceFormat = ( Key.isDown(70) && Key.isDown(Key.SPACE) )
		
		if(  card == null || flForceFormat  ){
			formatFruticard();
		}
		
		if( card.$vs < VERSION ){
			patchFruticard();			
		} 
		
		
		if( pref == null || flForceFormat ){
			formatPref();
		}
		
	}
	
	static function formatFruticard(){
		
		
		Manager.log("-Format card-")
		
		card = {
			$vs:VERSION
			
			$ultitem:false
			$arcade:[0]
			$fever:{
				$max:0
				$reward:[]
			}
			$chrono:{
				$record:null
				$prize:[0,1,2,3,4,5,6,7,8,9,10]
				$topPrize:true
			}
			
			$train:{
				$record:[]
				$prize:[true,true,true,true,true]
			}
			
			$play:[]	
		}
		
		
		
		//* HACK
		for( var i=0; i<100; i++ ){
			card.$play[i] = 199
		}
		//*/
		
		Manager.client.slots[0] = Std.cast(card); 
		Manager.client.saveSlot(0,null);
		
		if(Client.STANDALONE){
			downcast(so.data).fruticard[0] = card
		}
		
		
	}
	
	static function patchFruticard(){
		Manager.log("patch card !!!")
		/*
		if( card.$vs < 0.341 ){ // PATCH 0.341 initCheckpoints
			if(card.$checkpoint==null)card.$checkpoint=0;
		}
		*/
		
		card.$vs = VERSION
		save();
	}
	
	static function formatPref(){
		Manager.log("formatPref!")
		pref = {
			$mouse:false,
			$sound:[1,1],
			$key:[Key.LEFT,Key.RIGHT,Key.SPACE,Key.DOWN,Key.UP]
			
		}
		Manager.client.slots[1] = Std.cast(pref); 
		Manager.client.saveSlot(1,null);		
	}

	static function save(){
		Manager.client.saveSlot(0,null)
	}
	
	// ARCADE
	
	static function finishArcade(n){
		if(n<3 && card.$arcade[n+1] == null){
			card.$arcade[n+1] = 0
		}else{
			if(!card.$ultitem){
				card.$ultitem = true;
				Manager.client.giveItem("$ultitem")				
			}
		}
	
		
	}
	
	static function incPlay(n){
		

		if( card.$play[n] == null )card.$play[n] = 0;
		card.$play[n]++;
		
		if( card.$play[n]>=TRAIN_LIMIT && card.$train.$record[n] == null ){
			Manager.queue.push( { link:"congrat", infoList:[100,n] } )
			card.$train.$record[n] = 0;
		}
		
		
	}

	static function endChrono(result){
		
		var list = card.$chrono.$prize
		
		// RECORD
		var test = card.$chrono.$record
		if( test == null )test = 0x7fffffff
		if( result < test ){
			Manager.queue.push( { link:"congrat", infoList:[16,result] } )
			card.$chrono.$record = result
		}
			
		// ¨PRIZE
		if( result < CHRONO_LIMIT && list.length > 0 ){
			var index = Std.random(list.length)
			Manager.client.giveItem("$chrono_"+index)
			list.splice(index,1)
			Manager.queue.push( { link:"congrat", infoList:[80+index] } )
		
		}

		// WALLPAPER
		if( result < CHRONO_TOP_LIMIT && card.$chrono.$topPrize ){
			card.$chrono.$topPrize = false;
			Manager.client.giveItem("$wallpaper")
			Manager.queue.push( { link:"congrat", infoList:[90] } )
		}

		
	}
	
	static function trainResult(id:int,dif:int){
		
		var et = -1
		for( var i=0; i<POTIONS_DIF_LIST.length; i++ ){
			if(dif>=POTIONS_DIF_LIST[i])et=(i+1);
		}

		if(  et > card.$train.$record[id] ){
			card.$train.$record[id] = et
			Manager.queue.push( { link:"congrat", infoList:[20,id,et-1] } )
			checkPotions()
			return true;
		}
		return false;
	}
	
	static function checkPotions(){
		var list = card.$train.$record
		var pl = [0,0,0,0,0]
		for( var i=0; i<list.length; i++ ){
			var max = list[i]
			for( var n=0; n<max; n++ ){
				pl[n]++;
			}			
			/*
			var index = list[i]
			if(index!=null)pl[i]++;
			*/
		}
		
		for( var i=0; i<pl.length; i++ ){
			if( pl[i] >= TRAIN_PRIZE_LIMIT && card.$train.$prize[i] ){
				card.$train.$prize[i] = false;
				Manager.queue.push( { link:"congrat", infoList:[21,i] } )
				
				if( i<3 ){
					Manager.client.giveItem("$smiley_"+i)
				}else if( i==4 ){
					Manager.client.giveItem("$casquette")
				}else if( i==5 ){
					Manager.client.giveItem("$lunette")
				}				
			}
		}
		
		
	}
	
	
//{	
}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
