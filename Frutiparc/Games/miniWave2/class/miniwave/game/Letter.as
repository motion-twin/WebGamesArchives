class miniwave.game.Letter extends miniwave.Game{//}

	var shieldMax:Number = 8;
	var comboTimer:Number = 8;

	
	var kl:Object		// keyListener
	var shield:Number;
	
	
	var combo:Object;	
	
	var lifePanel:miniwave.panel.LetterLife
	
	function Letter(){
		this.init();
	}
	
	function init(){
		_root.test += "Letter Invader ! \n"
		super.init();
		
		this.initKeyListener();
		
		this.fadeCb = {
			obj:this,
			method:"initStep",
			args:0
		}
		//this.level = 0
		
	};

	function initDecor(){
		super.initDecor();
		this.decor.gotoAndStop(4 );
		this.decor.bg0.gotoAndStop(1)
		this.decor.bg1.gotoAndStop(2)
		this.decor._y = this.mng.mch;
	}	
	
	function update(){
		if( this.checkWaveInfoLoading() )return;
		super.update();
		switch(this.step){

			case 0 :	// PANEL
				
				//for(var i=0; i<this.msgList.length; i++ )this.msgList[i].update();
				break;
			case 1 :	// WAVING
				//this.updateSprites();
				if( this.isWaveReady() ){
					this.initStep(2)
				}
				this.checkCombo();
				break;
			case 2 :	// GAME
				//this.updateSprites();
				this.updateWave();
				//
				this.checkEnd();
				this.checkCombo();
				break;
			case 3 : 	// FORWARD
				//this.updateSprites();
				// ENDTIMER
				/*
				this.timer -= Std.tmod
				var c = this.timer/this.endTimerMax;
				this.decor._y = (this.level+1-c)*this.decorDecal
				if( this.timer <0 ){
					this.level++;
					this.initStep(0);
				}
				*/
				this.timer -= Std.tmod
				var c = this.timer/this.endTimerMax;
				var d = (this.nextLevel-this.level)*c
				var dy = ((this.nextLevel-d)*this.decorDecal)
				this.moveMap(dy)

				if( this.timer <0 ){
					this.level = this.nextLevel;
					this.initStep(0);
				}

				break;
			
		}

		this.moveAll();
	}
		
	function initInterface(){
		super.initInterface();
		this.lifePanel = this.newPanel( "miniWave2PanelLetterLife" )
		//_root.test+="this.lifePanel("+this.lifePanel+")\n"
		this.lifePanel.addLife(4)
		
	}
	
	function initStep( step ){
		this.step = step;
		switch( this.step ){
		
			case 0:	// NEW LEVEL
				/*
				var info = this.waveInfo[this.level]
				var initObj = {
					type:0,
					timer:80,
					list:[ "level "+(this.level+1), info.name ],
					cb:{ obj:this, method:"initStep", args:1 }
				}
				*/
				var info = this.waveInfo[this.level]
				if( info != undefined ){
					var initObj = {
						type:0,
						timer:80,
						list:[ "level "+(this.level+1), info.name ],
						cb:{ obj:this, method:"initStep", args:1 }
					}
				}else{
					var initObj = {
						type:2,
						timer:160,
						list:[ "Bravo vous avez exterminé les infames letter-Monsters !!" ],
						cb:{ obj:this, method:"endGame" }
					}				
				}
				this.genMsg(initObj)	
				break;
			case 1: // WAVING
				this.initLevel();
				break;
			case 2: // GAME
				for( var i=0; i<this.badsList.length; i++ ){
					this.badsList[i].startWaveAttack();
				}
				break;
			case 3: // FORWARD
				this.timer = this.endTimerMax;
				this.cleanShots()				
				break;
		}
	}

	function initKeyListener(){
	
		this.kl = new Object();
		this.kl.obj = this;
		this.kl.onKeyDown = function () {
			this.obj.pushKey();
		}
		this.kl.onKeyUp = function () {
			
		}
		Key.addListener(kl);
		
		
		
	}

	function checkEnd(){
		if(toKill<=0  && this.combo == undefined ){
			this.nextLevel = this.level+1
			this.initStep(3)
		};		
	}	
	
	function updateWave(){
		super.updateWave();
		for( var i=0; i< this.badsList.length; i++ ){
			var mc = this.badsList[i]
			if( mc.y+mc.ray > this.mng.mch ){
				var initObj = {
					type:1,
					list:[  ]
				}
				this.gameOver(initObj);
			}
			
		}		
		
	}
	
	function newBads( type, initObj ){
		if( initObj == undefined ) initObj  = new Object();
		do{
			
			if( level>10 ){
				initObj.code = random(36)
			}else{
				initObj.code = random(26)
			}
		}while( initObj.code == 15 || initObj.code == 26 )
		
		
		var mc = super.newBads( 50, initObj )
		//_root.test+="mc("++")\n"
		return mc;
	}	

	function pushKey(){
		//_root.test+="c("+c+")\n"
		var c = Key.getCode();
		if( this.flGameOver || this.step==0 || this.step==3 || this.mng.flPause )return;
		if( !((c>=65 && c<91) || (c>48 && c<58) || (c>96 && c<106)) || c==80 ){
			return;
		}

		
		
		for( var i=0; i<this.badsList.length; i++ ){
			var mc = this.badsList[i];
			/*
			if( mc.code+65 == c ){
				this.hit(mc);
				return;
			}
			*/
			for( var k=0; k<mc.keyCode.length; k++ ){
				if( mc.keyCode[k] == c ){
					this.hit(mc);
					return;
				}
			}
			
			
		}
		if( this.lifePanel.removeLife(1) ){
			var initObj = {
				type:1,
				list:[  ]
			}
			this.gameOver(initObj);
		}

	}
	
	function hit(mc){
		mc.explode();
		
		if(combo!=undefined){
			this.combo.num++
			this.combo.timer = this.comboTimer;
			
			if( combo.num == 2 ){
				this.combo.path = this.newPart("miniWave2SpPartCombo",{flGrav:false});
				//_root.test+="combo.path("+this.combo.path+")\n"
			}
			this.combo.path.txt = "combo "+this.combo.num
			
		}else{
			this.combo = {
				num:1,
				timer:this.comboTimer
			}
		}
	}
	
	function checkCombo(){
		if( this.combo!=undefined ){
			if( this.combo.timer < 0 ){
				if( this.combo.num > 1 ){
					var score = Math.pow(this.combo.num,2)*10
					this.incScore(score)
					this.combo.path.txt+=" +"+score
					this.combo.path.gotoAndPlay("death");
				}
				delete this.combo;
			}else{
				this.combo.timer -= Std.tmod;
			}
			
		}
	}

	function getWaveName(){
		return "letterWave"
	}
	
	function endGame(){
		this.mng.fc[0].$letter = Math.max( this.mng.fc[0].$letter, this.score );
		
		var p = this.getCons();
		if( p > this.mng.fc[0].$cons.$letter ){
			this.mng.fc[0].$cons.$letter = p
			if( p == 100 ){
				this.mng.client.giveItem("$letter");
				this.mng.newTitem++
			}
		}

		super.endGame();
	}
	
	function onPause(){
		super.onPause();
		for( var i=0; i<this.badsList.length; i++){
			this.badsList[i]._visible = !this.mng.flPause
		}
	}
	
	// STATS
	function addNewPlay(){
		super.addNewPlay("$letter")
	}	
	
	// KILL
	function kill(){
		Key.removeListener(this.kl)
		super.kill();
	}

	
//{	
}














