_root.test=""
createEmptyMovieClip("loader",20)
loader.fruitList = new Array();
loader.libList = [
	{ name:"bumdum",	url:"lib/bumdum.swf"	},
	{ name:"jeu", 		url:"lib/game.swf"	},
	{ name:"menu", 		url:"lib/menu.swf"	}
]
loader.fNum = 0



loader.createFruit = function(size){
	//size+=random(100)
	var d = loader.fNum++
	this.attachMovie("pomme","fruit"+d,d);
	var mc = this["fruit"+d];
	mc._x = 10//size/2;
	mc.x = 10;
	mc._y = 480-(10+size/2);
	mc._xscale = size;
	mc._yscale = size;
	mc.stop();
	mc.circ = Math.PI*size
	this.fruitList.push(mc)
	return mc;
}

loader.moveFruit = function(){
	
	for( var i=0; i<this.fruitList.length; i++ ){
		var fruit = this.fruitList[i];
		var c = fruit.getBytesLoaded()/fruit.getBytesTotal();
		var x = 10+(c*680)
		//fruit.x = fruit.x*0.95 + x*0.05
		fruit.x = x
		var dif = fruit.x-fruit._x;
		fruit._x = fruit.x
		fruit._rotation += (dif/fruit.circ)*360
		if(fruit.ready && fruit._x>600){
			if(this.libLoaded==this.libList.length){
				gotoAndPlay("start");
				loaderKill();
			}else{
				this.initNextLoad();
				fruit.ready=false;
			}			
		}
	}
}


function loaderInit(){
	

		//_root.test+="[loader] init("+createFruit+");\n"
		loader.libLoaded = 0;
		loader.mcl = new MovieClipLoader();
		loader.mcl.obj = loader
		loader.mcl.onLoadStart = function(mc){
			//_root.test += "start()\n"
		}
		loader.mcl.onLoadInit = function(mc){
			//_root.test += "init()\n"
		}
		loader.mcl.onLoadError = function(mc,error){
			//_root.test += "error("+error+")\n"
		}		
		loader.mcl.onLoadComplete = function(mc){
			//_root.test += "complete toLoad("+this.obj.libLoaded+");\n"
			this.obj.libLoaded++;

			mc.path.ready = true;
		}
		loader.mcl.onLoadProgress = function(mc){
			//_root.test += "progress("+mc.flInit+") mc.path._x("+ mc.path._x+")\n"
			if(mc.flInit){
				fruit = mc.path
			}else{
				mc.path = this.obj.createFruit( Math.pow(mc.getBytesTotal(),0.7)/80 )//mc.getBytesTotal()/2000)
				mc.flInit = true;
			}
		}
		
		loader.initNextLoad();
		/*
		var total = _parent.getBytesTotal();
		//var mc = createFruit(total/5000)
		//fruitList.push({link:this,fruit:mc,name:"jeu"})
		*/
		
		/*
		for(var i=0; i<loader.libList.length; i++){
			
			createEmptyMovieClip("lib"+i,10+i)
			var lib = this["lib"+i]
			loader.mcl.loadClip( loader.libList[i].url, lib )

			//fruitList.push( { link:libList[i].link, fruit:mc, name:libList[i].name } )
		}
		*/
		//loader.toLoad = loader.libList.length

	
};

loader.initNextLoad = function(){
	//_root.test+="initNextLoad("+this.libLoaded+")\n"
	var d = this.libLoaded
	this._parent.createEmptyMovieClip("lib"+d,2+d)
	var lib = this._parent["lib"+d]
	this.mcl.loadClip( this.libList[d].url, lib )	
}

function loaderLoop(){
	//_root.test+="a"
	loader.moveFruit();
};

function loaderKill(){
	 loader.removeMovieClip("")
}



