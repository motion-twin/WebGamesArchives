class kaluga.game.Trial extends kaluga.Game{//}
	
	var nbTry:Number;
	var trialId:Number;
	

	// REFERENCES
	var squirrel:kaluga.sp.bads.Squirrel;
	
	function Trial(){
		
	}
	
	function init(){
		//_root.test+="[Trial] init\n"
		super.init();
	}
		
	function initDefault(){
		if(this.card == undefined) 	this.card = this.mng.card.$trial.$list[this.trialId];
		super.initDefault();
	}
		
	function addScore(){
		
		switch(this.mode){
			case "single" :
				// VERIFIE POUR AJOUTER OU MAJ LE SCORE
				var list = this.card.$list
				//var now = "pouet!"					// a coder
				//var data = list[list.length-1]
				/*
				_root.test = "card data :\n"
				_root.test += "last.$d = "+data.$d+"\n"
				_root.test += "last.$s = "+data.$s+"\n"
				_root.test += "last.$t = "+data.$t+"\n"
				_root.test += "$max = "+this.card.$max+"\n"
				_root.test += "$list = "+this.card.$list+"\n"
				*/

			
				/*
				if(data.$d != now){
					list.push({$d:{$d:24,$m:01,$y:2003},$s:this.score,t:this.tzongreInfo.id});
				}else{
					if(this.score>data.$s){
						data.$s=this.score;
						data.$t=this.tzongreInfo.id
					}
				}
				*/
				list.push({$s:this.score,$t:this.tzongreInfo.id});
				
				while(list.length>12)list.shift();
				
				// MET LE MAX DE LA CARD A JOUR
				if(this.score>this.card.$max){
					this.card.$max=this.score;
					//
					var o = {
						label:"congrat",
						list:[
							{
								type:"congrat",
								text:"Record général battu!!\n",
								id:12
							}
						]
					};
					this.endPanelMiddle.push(o);
				}
		
				// VERIFIE POUR LA MEILLEURE TZONGRE
				var data = this.card.$tz[this.tzongreInfo.id]
				var best;
				if(data.$s==undefined)best=0;else best=data.$s; //if(data.$s==undefined)best=0;else;best=data.$s;
				if(this.score>best){
					//if(data==undefined)data= new Object();
					//data.$d=now
					data.$s=this.score;
					data.$t=this.tzongreInfo.id
					var o = {
						label:"congrat",
						list:[
							{
								type:"congrat",
								text:"Félicitation!\nVous avez amélioré le score maximum de "+this.tzongreInfo.name+" !!\n",
								id:this.tzongre.id
							}
						]
					};
					this.endPanelMiddle.push(o);
				}
				
				// ENDPANEL
				// LAST 8
				var maxResult = 8
				var statList = new Array();
				var start = Math.max(list.length-maxResult,0)
				for( var i=start; i<list.length; i++ ){
					var data = list[i];
					var obj = {
						value:data.$s/this.card.$max,
						num:data.$s,
						color:this.mng.color.tzPastel[data.$t]
					}
					statList.push(obj)
				}
				var obj = this.getEndPanelObj(statList);
		
				// BEST TZONGRE
				var maxResult = 5
				var statList = new Array();
				var max = 0		
				
				for( var i=0; i<this.card.$tz.length; i++ ){
					var n = this.card.$tz[i].$s
					if ( n != undefined ) max = Math.max( n, max );
				}
				for( var i=0; i<this.card.$tz.length; i++ ){
					var data = this.card.$tz[i];
					var o = {
						value:data.$s/max,
						num:data.$s,
						color:this.mng.color.tzPastel[i]
					}
					statList.push(o)
				}
				var obj2 = {
					//label:"caterLaunch",
					list:[
						{
							type:"title",
							title:"Meilleure Tzongre"
						},
						{
							type:"margin",
							value:15
						},
						{
							type:"graph",
							gfx:"partGraphBar",
							box:{x:20,y:6,w:420,h:264},
							//color:{main:this.mng.color.tzPastel[this.tzongreInfo.id],line:0xFFFFFF},
							maxResult:5,
							margin:10,
							marginInt:6,
							list:statList,
							flNumber:true,
							flBackground:true,
							flTriangle:true
						}
					]
				}
				
				this.endPanelMiddle.push(obj,obj2)
				break;
			case "triathlon" :
				//_root.test+="youhouhou!\n"
			
				break;
				
			case "heptathlon" :
				break;
		
		}
		
		// SAVE SLOT
		this.mng.client.saveSlot(0)		
	}
	
	function initEndGame(timer){
		//_root.test+="[TRIAL]initEndGame"
		switch( this.mode ){
		
			case "triathlon":
				var max = 2
			case "heptathlon":
				if( max == undefined ) max = 6;
				//
				this.updateTournament();
				//_root.test+=" eventId("+this.tournament.eventId+"->"	
				this.tournament.eventId++;
				_root.test+=this.tournament.eventId+") "
				//
				var obj = {
					list:[
						{
							type:"title",
							title:" Resultats "
						},
						{
							type:"margin",
							value:8
						},
						{
							type:"table",
							box:{x:20,y:6,w:460,h:264},
							stats:this.tournament.stats
						}
					]
				}
				//_root.test+="push\n"
				this.endPanelMiddle.push(obj);
				//
				if( this.tournament.eventId > max ){
					this.endTournament();
			
				}			
				break;			
		}
		
		super.initEndGame(timer);
		//_root.test+="\n"
	}
	
	function endTournament(){
		
		var list = new Array();
		var score = 0
		for( var i=0; i<this.tournament.stats.length; i++ ){
			var player = this.tournament.stats[i];
			var sum = 0;
			for( var s=0; s<player.results.length; s++ ){
				sum += player.results[s].score
			}
			list[i] = {id:player.id, sum:sum}
			
			if( player.id == this.tzongreInfo.id ){
				score = sum
			}
			
			/*
			if( player.id == this.tzongreInfo.id ){
			}else{
				this.updateResult(player);
			}
			*/
		}
		
		var f = function(a,b){
			if( a.sum > b.sum )	return -1;
			if( a.sum == b.sum )	return 0;
			if( a.sum < b.sum )	return 1;
		}
		
		list.sort(f);
		
		var flWin = list[0].id == this.tzongreInfo.id
		var tz = this.mng.tzInfo
		var text = tz[list[0].id].name+" gagne facilement ce "+this.mode+" !!!\n"
		text += tz[list[1].id].name+" emporte la médaille d'argent et "+tz[list[2].id].name+" prend la 3ème place !\n"
		text += "Notons la pietre performance de "+tz[list[4].id].name+" qui se place a la dernière place avec "+list[4].sum+" points!\n"
		
		var o = {
			label:"ladder",
			list:[
				{
					type:"ladder",
					text:text,
					list:list
				}
			]
		};
		this.endPanelMiddle.push(o);
		/* trace le resultat du tournoi
		_root.test+="Resultat du tournoi :\n"
		for( var i=0; i<list.length; i++){
			var name = this.mng.tzInfo[list[i].id].name
			_root.test+="- ("+i+") : "+name+" ("+list[i].sum+")\n"
		}
		*/
		
		// MESSAGE DE VICTOIRE	
		if( this.mng.client.isWhite() ){			
			
			// UNLOCK
			if(flWin){
				switch(this.mode){
					
					case "triathlon":
						var o = {
							label:"congrat",
							list:[
								{
									type:"congrat",
									text:"Vous avez débloqué 4 nouvelles épreuves ainsi que le mode heptathlon !\n",
									id:10
								}
							]
						};
						this.endPanelMiddle.push(o);
						this.mng.card.$mode[1][3] = 1;
						this.mng.card.$mode[1][4] = 1;
						this.mng.card.$mode[1][5] = 1;
						this.mng.card.$mode[1][6] = 1;
						this.mng.card.$mode[1][8] = 1;
						this.addKagulga();
						this.mng.client.saveSlot(0)

						
						break;
	
					case "heptathlon":
						var o = {
							label:"congrat",
							list:[
								{
									type:"congrat",
									text:"Vous avez terminé le mode heptathlon, félicitation !!!\n",
									id:10
								}
							]
						};
						this.endPanelMiddle.push(o);
						this.mng.card.$seq[1] = 1
						this.mng.client.saveSlot(0)
						this.addTitem("$allstar")
						break;
				}
			}
			
			// MEILLEUR SCORE FCARD
			var n;
			switch(this.mode){
				case "triathlon":
					n = "$tria"
					break;
				case "heptathlon":
					n = "$hept"
					break;				
			}
			
			if( score>this.mng.card.$trial[n].$s ){


				
				var o = {
					label:"congrat",
					list:[
						{
							type:"congrat",
							text:"Record général battu !!\nAncien record: "+this.mng.card.$trial[n].$s+" pts\nNouveau record: "+score+" pts",
							id:12
						}
					]
				};
				this.endPanelMiddle.push(o);
				
				this.mng.card.$trial[n].$s = score
				this.mng.card.$trial[n].$t = this.tzongreInfo.id
				this.mng.client.saveSlot(0)
				
			}			
			
			
		}
		
		// SAUVEGARDE DU SCORE
		if(score>0){
			this.saveScore(score)
		};




		
	}
	
	function updateTournament(){
		//_root.test+="updateTournament\n"
		if( this.score == undefined ) this.score = 0;
		for( var i=0; i<this.tournament.stats.length; i++ ){
			var player = this.tournament.stats[i];
			if( player.id == this.tzongreInfo.id ){
				var results = player.results[this.tournament.eventId]
				results.base = this.score;
				results.score = results.base*results.coef;
			}else{
				this.updateResult(player);
			}
		}
				
		//_root.test =""
		//this.mng.traceVar(this.tournament)
		
	}
	
	function updateResult(player){
		var results = player.results[this.tournament.eventId]
		results.base = Math.round(results.base*10)/10
		results.score = results.base*results.coef;
	}

	function getEndPanelObj(){
	}
	
	function attachMeterLog(x,y,text){
		
		var d = this.fxNum++;
		var initObj ={
			x:x,
			y:y,
			text:text
			//mode:1
		}
		var mc = this.newDecor("meterLog",initObj)
		//_root.test+="attachMeterLog("+mc+")\n"
		return mc;
	}	
	
	function genSquirrelJudge(x){
		var initObj = {
			mode:2,
			x:x,
			y:this.map.height - this.map.groundLevel,
			flLinkable:false
		}
		this.squirrel = this.newSquirrel(initObj);
		this.squirrel.endUpdate();
	}
	
//{	
}