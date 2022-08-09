class Level {//}


	//
	var fupdate : void -> void;
	var game : Game;
	var tbl : Array<Array<Bille>>;
	var groups : Array<Array<Bille>>;
	var rList : Array<{b:Bille,b2:Bille,r:int,p:Part}>
	//


	//
	var index:int;
	var step:int;
	volatile var timer:float;

	var panel:{>MovieClip,p:MovieClip, flGo:bool}


	function new(g) {
		game = g;

	}

	function init() {
		var x,y;
		tbl = new Array();
		for(x=0;x<Const.WIDTH;x++) {
			tbl[x] = new Array();
			for(y=0;y<Const.HEIGHT;y++) {
				var t;
				do {
					t = Std.random(4);
				} while( t == tbl[x-1][y].t || t == tbl[x][y-1].t );
				var b = new Bille(game,t);
				b.setPos(x,y);
			}
		}
		var i;
		for(i=0;i<4;i++) {
			var t = tbl[Std.random(Const.WIDTH)][Std.random(Const.HEIGHT)];
			if( t.t < Const.ID_BONUS )
				t.setSkin(Const.ID_MONSTER);
			else
				i--;
		}
		var nbonus = 1+Std.random(5);
		for(i=0;i<nbonus;i++) {
			var t = tbl[Std.random(Const.WIDTH)][Std.random(Const.HEIGHT)];
			if( t.t < Const.ID_BONUS )
				t.setSkin( Const.ID_BONUS );
			else
				i--;
		}
	}

	function swap(b1,b2) {
		var me = this;
		game.dmanager.over(b1.mc);
		game.dmanager.over(b2.mc);
		fupdate = fun() {
			var r1 = b1.moveTo(b2.x,b2.y);
			var r2 = b2.moveTo(b1.x,b1.y);
			if( !r1 && !r2 ) {
				var p1 = { x : b1.x, y : b1.y };
				b1.setPos(b2.x,b2.y);
				b2.setPos(p1.x,p1.y);
				me.swapDone();
			}
		};
	}

	function makeGroupsRec(b : Bille,x : int,y : int,g : Array<Bille>) {
        var t = b.t;
        b.group = g;
        g.push(b);
        b = tbl[x-1][y];
        if( b.t == t && b.group == null )
            makeGroupsRec(b,x-1,y,g);
        b = tbl[x+1][y];
        if( b.t == t && b.group == null )
            makeGroupsRec(b,x+1,y,g);
        b = tbl[x][y-1];
        if( b.t == t && b.group == null )
            makeGroupsRec(b,x,y-1,g);
        b = tbl[x][y+1];
        if( b.t == t && b.group == null )
            makeGroupsRec(b,x,y+1,g);
    }

	function makeGroups() : bool {
        var x,y;
        for(x=0;x<Const.WIDTH;x++)
            for(y=0;y<Const.HEIGHT;y++)
                tbl[x][y].group = null;
        groups = new Array();
        var exists = false;
        for(x=0;x<Const.WIDTH;x++)
            for(y=0;y<Const.HEIGHT;y++) {
                var g = tbl[x][y];
                if( g != null && g.group == null ) {
                    var grp = new Array();
                    makeGroupsRec(g,x,y,grp);
                    if( grp.length > 1 )
                        groups.push(grp);
                    exists = true;
                }
            }
		return exists;
    }

	function walls() {
		var i,j;
		for(i=0;i<groups.length;i++) {
			var g = groups[i];
			if( g.length > 2 && g[0].t < Const.ID_BONUS ) {
				for(j=0;j<g.length;j++) {
					var b = g[j];
					game.flash(b.mc)
					b.setSkin(Const.ID_WALL);
					for( var n=0; n<10; n++ ){
						var p = game.newPart("partFlushee")
						var a = Math.random()*6.28
						var ca = Math.cos(a)
						var sa = Math.sin(a)
						var r = 14+Math.random()*2
						p.x = b.px + ca*r;
						p.y = b.py + sa*r;
						p.vitx = ca*r*0.05
						p.vity = sa*r*0.05
						p.timer = 6+Math.random()*12
						p.scale = 50 + Math.random()*80
						p.init();
					}
				}
			}
		}
	}

	function reproduce(max : int) : bool {
		var x,y;
		var dirs = [{ x : 1, y : 0, id:0 },{ x : 0, y : 1, id:1 },{ x : -1, y : 0, id:2 },{ x : 0, y : -1, id:3 }];
		var changed = false;
		var changeable = false;
		for(x=0;x<Const.WIDTH;x++)
			for(y=0;y<Const.HEIGHT;y++) {
				var b = tbl[x][y];
				if( b.t >= Const.ID_MONSTER ) {
					var d = Tools.shuffle(dirs);
					var i;
					for(i=0;i<4;i++) {
						var b2 = tbl[x+d[i].x][y+d[i].y];
						if( b2.t < Const.ID_WALL ) {
							changeable = true;
							if( b.group == null || max == 0 || Std.random(int(Math.sqrt(b.group.length))) != 0 )
								break;
							max--;
							changed = true;
							b2.setSkin(b.t);
							b2.group = null;
							rList.push({b:b,b2:b2,r:d[i].id,p:null})
							break;
						}

					}
				}
			}
		if( max > 0 && !changed && changeable )
			return reproduce(max);
		return changeable;
	}

	function swapDone() {
		var me = this;
		fupdate = null;
		makeGroups();
		walls();

		rList = new Array();
		reproduce(5);
		if( !reproduce(0) ) {
			initDestroy();
			return;
		}
		initSplash();

		//
	}

	function initDestroy(){
		step = 0
		index = 0
		timer = 0
		fupdate = callback(this,destroy);
		attachPanel();
	}

	function destroy() {
		//Log.print(timer)
		timer -= Timer.tmod
		if(timer<0){
			while(true){
				var flBreak = false;
				var x = index%Const.WIDTH
				var y = Math.floor(index/Const.HEIGHT)
				var t = tbl[x][y]

				switch(step){
					case 0:
						if(t.t==Const.ID_MONSTER){
							t.score();
							flBreak = true;
						}
						break;
					case 1:
						if(t.t==Const.ID_WALL){
							t.score();
							flBreak = true;
						}
						break;
					case 2:
						if(t.t<4){
							t.score();
							flBreak = true;
						}
						break;
					case 3:
						if( t.t == Const.ID_BONUS ){
							t.score();
							flBreak = true;
						}
						break;
					case 4:
						flBreak = true;
						break;
				}

				index++
				var max = Const.WIDTH*Const.HEIGHT
				if( index >= max ){
					index = 0;
					step ++;
					flBreak = true;
					timer = 10
					if(step>3){
						panel.flGo = true;
						fupdate = null;
						KKApi.gameOver(game.stats);
					}else{
						if(panel!=null)panel.flGo = true;
						attachPanel();
					}
				}

				if(flBreak)break;
			}
			timer += 1.5
			if( step == 3 ) timer += 16;
			if( step == 1 ) timer += 4;

		}



	}

	function attachPanel(){
		panel = downcast( game.dmanager.attach( "mcPanel", Const.PLAN_PANEL ) )
		panel.p.gotoAndStop(string(step+1))
		panel._x = 300;
		panel._y = 300;
	}

	function initSplash(){
		index = 0;
		fupdate = callback(this,splash);
		for( var i=0; i<rList.length; i++ ){
			var info = rList[i]
			info.b2.mc._alpha = 0;
			var p = game.newPart("animBlob")
			p.x = info.b.px;
			p.y = info.b.py;
			p.fadeTypeList = [1]
			p.init();
			p.skin._rotation = info.r*90
			p.skin._alpha = 0
			info.p = p;
		}
	}

	function splash(){
		index++


		if(index<=5){

			for( var i=0; i<rList.length; i++ ){
				var info = rList[i]
				info.p.skin._alpha = index*20
				info.b.mc._alpha = 100-info.p.skin._alpha
			}
		}

		if(index==20){
			for( var i=0; i<rList.length; i++ ){
				var info = rList[i]
				info.b.mc._alpha = 100-(25-index)*20;
				info.b2.mc._alpha = 100-(25-index)*20;
			}
		}

		if(index>20){
			for( var i=0; i<rList.length; i++ ){

				var info = rList[i]
				info.b.mc._alpha = 100-(25-index)*20;
				info.b2.mc._alpha = 100-(25-index)*20;
				if(index==21)downcast(info.b.mc).sub.play();
				if(index==23)downcast(info.b2.mc).sub.play();
			}
		}

		if( index == 12  ){
			var ray = 4
			for( var i=0; i<rList.length; i++ ){
				var info = rList[i]
				var x = (info.b.px+info.b2.px)*0.5
				var y = (info.b.py+info.b2.py)*0.5

				for( var n=0; n<4; n++ ){
					var p = game.newPart("partMonster")
					var a = Math.random()*6.28
					var ca = Math.cos(a)
					var sa = Math.sin(a)
					var sp = 0.2+Math.random()*0.8
					p.x = x+ca*ray
					p.y = y+sa*ray
					p.vitx = ca*sp;
					p.vity = sa*sp;
					//p.fadeTypeList = [1]
					p.timer = 10+Math.random()*10
					p.init();
				}
			}
		}

		if(index==30){
			game.lock = false;
			fupdate = null;
		}


	}

	function main() {
		fupdate()
	}
//{
}










