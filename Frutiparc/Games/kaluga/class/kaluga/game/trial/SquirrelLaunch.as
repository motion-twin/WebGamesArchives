class kaluga.game.trial.SquirrelLaunch extends kaluga.game.Trial{//}

	// CONSTANTES
	var outMargin:Number = 40;
	
	// VARIABLES
	var flValidate:Boolean;
	var flMark:Boolean;
	var step:Number;
	var waitTimer:Number;
	var squirrelPoint:Number;
	
	// REFERENCES
	var squirrel:kaluga.sp.bads.Squirrel;
	var mcMark:MovieClip;
	
	
	function SquirrelLaunch(){
		this.init();
	}
	
	function init(){
		this.type = "$squirrelLaunch"
		this.trialId = 2
		this.mapInfo ={
			skinLink:this.mng.client.getFileInfos("map/squirrel.swf").name,
			width:1000,
			height:2820,
			flScroll:true
		}
		super.init();
		this.step = 0;
		this.flMark=false;
		this.initScroller();
	}

	function initStartPanel(){
		super.initStartPanel();
		this.startPanel.toRead = 3;
	};
	
	function initSprites(){
		super.initSprites();
		this.genTzongre();
		this.genSquirrel();
		
		this.newDecor("decorMegarbre",{x:500,y:this.map.height-(this.map.groundLevel+1250)})
		
		this.newDecor("decorMegarbreBase",{x:500,y:this.map.height-(this.map.groundLevel)})
		//this.newDecor("decorMegarbreFeuillage",{x:500,y:this.map.height-(this.map.groundLevel+2000)})
	}
	
	function genTzongre(){
		var initObj = this.tzongreInfo
	
		initObj.x = this.map.width/2
		initObj.y = this.map.height-kaluga.Cs.mch/2
		initObj.vity = -4
		initObj.flLauncher = true

		this.tzongre = this.newTzongre(initObj);
		var box = {
			left:0,
			top:this.map.height-kaluga.Cs.mch,
			right:this.map.width,
			bottom:this.map.height		
		}
		this.tzongre.setBox(box)
		this.setTzongreFocus();
		this.moveMap(false)
		//this.map.update()
		this.tzongre.endUpdate();
		
	};
	
	function genSquirrel(){
		var initObj = {
			x:0,
			y:this.map.height - this.map.groundLevel
		}
		this.squirrel = this.newSquirrel(initObj);
		//this.squirrel.weight = -0.1	// hack
		this.squirrel.endUpdate();
		this.squirrel.setSens(1)
		
	}
	
	function initDefault(){
		super.initDefault();
	}
	//
	function update(){
		
		switch(this.step){
			case 0 :	// PREPARATION
				super.update();
				break;
			case 1 :	// SOULEVER
				super.update();
				break;			
			case 2 :	// LANCER
				super.update();
				if(this.flLinkActive)this.deActiveLink();
				if(!this.flMark && this.squirrel.vity>0){
					this.attachMark()
				}
				
				this.checkOut()
				
				break;
			case 3 :	// WAIT
				this.waitTimer -= kaluga.Cs.tmod;
				if(this.waitTimer<0){
					this.step=4;
					this.activeLink();
				}
				
				break;
			case 4 :	// FALLING
				if(this.camFocus.type=="Squirrel" && this.squirrel.vity>2.5){
					this.setTzongreFocus()
				}
				this.checkGround()
				this.checkOut()
				super.update();
				break;
			case 5 :	// CATCH
				this.waitTimer -= kaluga.Cs.tmod;
				if(this.waitTimer<0){
					this.score = this.squirrelPoint;
					this.addScore();
					this.endGame();
					this.step = 99
				}				
				this.checkGround()
				super.update();
				break;
			case 99 :
				super.update();
				break;				
				
		}
		//_root.test=this.step;
		//_root.test="<"+this.step+">\n"
		
		//this["marker"]._x = this.launchPoint+this.mapDecal.x;
	}
	//
	function onTzRelease(tzongre){
		this.setCameraFocus(tzongre.linkList[0])
		this.setCameraBox("wide")
		if(this.step==1)this.step++;
		//this.map.initRuler(this.launchPoint);
	}

	function onTzLink(tzongre){
		//this.focus = tzongre.linkList[0]
		if(!this.flMark){
			this.step = 1;
		}else{
			this.step = 5;
			this.waitTimer = 50;
			this.squirrel.weight*=2.5
		}
	}
	
	function getEndPanelObj(statList){
		var obj = {
			//label:"squirrelLaunch",
			list:[
				{
					type:"bigScore",
					frame:1,
					score:this.score+"cm"
				},
				{
					type:"bigScore",
					frame:2,
					score:this.card.$max+"cm"
				},
				{
					type:"margin",
					value:15
				},
				{
					type:"graph",
					gfx:"partGraphBar",
					box:{x:20,y:6,w:420,h:230},
					//color:{main:this.mng.color.tzPastel[this.tzongreInfo.id],line:0xFFFFFF},
					margin:10,
					marginInt:6,
					list:statList,
					flNumber:true,
					flBackground:true,
					flTriangle:true
				}
			]
		}
		
		if( this.mng.client.isWhite() ){
 			if( !this.mng.card.$bonus[1] && this.score > 1000 ){
				this.addTitem("$squirrel1");
				this.mng.card.$bonus[1] = 1;
				this.mng.client.saveSlot(0);
			}
		}		
		
		return obj;		
	}
	
	function checkGround(){
		if( this.squirrel.flGround){
			this.step = 99;
			this.faultGround();
			
		}
	
	}
	
	function checkOut(){
		var x = this.squirrel.x
		if( x<-this.outMargin or x>this.map.width+this.outMargin ){
			this.step = 99;
			this.faultOut();
			
		}	
	}
	
	function faultGround(){
		var obj = {
			label:"basic",
			list:[
				{
					type:"msg",
					title:"Faute!",
					msg:"Pour que le lancer soit validé, il faut rattraper l'écureuil avant qu'il ne touche le sol."
				}
			]
		}
		this.endPanelStart.push(obj)		
		this.endGame();
	}
	
	function faultOut(){
		var obj = {
			label:"basic",
			list:[
				{
					type:"msg",
					title:"Hors-limite!",
					msg:"Pour que le lancer soit validé, L'écureuil doit rester dans les limites de la zone de tir."
				}
			]
		}
		this.endPanelStart.push(obj)		
		this.endGame();
	}	
	
	function attachMark(){
		var y = Math.round(((this.map.height-this.map.groundLevel)-this.squirrel.y)*10)/10;
		var obj = this.newDecor("heightLine",{x:0,y:this.squirrel.y, width:this.map.width });
		var mc = obj.path
		if(this.squirrel.x<this.map.width-120){
			mc.f._x = this.squirrel.x+70
		}else{
			mc.f._x = this.squirrel.x-70
		}

		mc.f.f.field.text=y+"cm"
		//mc.field._visible = false;
		this.flMark = true;
		this.waitTimer = 32;
		this.squirrelPoint = y;
		this.step = 3;	
			
	}
	
	function setTzongreFocus(){
		var box = {
			x:0,
			y:-(this.map.height-kaluga.Cs.mch),
			w:this.map.width,
			h:this.map.height
		}
		this.setCameraBox(box);
		this.setCameraFocus(this.tzongre)
	}

	function updateResult(player){
		var score;
		switch(player.id){
			case 0: // KALUGA
				score = 9000+random(4000)	// 1100
				break;
			case 1: // PIWALI
				score = 8000+random(5000)	// 1050
				break;
			case 2: // NALIKA
				score = 9000+random(3000)	// 1050
				break;
			case 3: // GOMOLA
				score = 12000+random(6000)	// 1500
				break;
			case 4: // MAKULO
				score = 8000+random(10000)	// 1300
				break;
		}
		score *= this.tournament.difCoef/10;
		player.results[this.tournament.eventId].base = score;
		super.updateResult(player);
	}
	
//{	
}






















