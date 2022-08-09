class Group{//}

	var list:Array<sp.el.Token>
	var game:Game;
	
	function new(g){
		list = new Array();
		game = g;
		game.gList.push(this);
	};  
	
	function addElement(e){
		e.group = this;
		list.push(e)
	}
	
	function removeElement(e){
		e.group = null
		for( var i=0; i<list.length; i++ ){
			if( e == list[i] ){
				list.splice(i,1)
				draw();
				return;
			}
		}
	}
	
	
	function eat(group){
		for( var i=0; i<group.list.length; i++ ){
			var e = group.list[i];
			e.group = this;
			list.push(e);
			for( var n=0; n<game.gList.length; n++){
				if( game.gList[n] == group ){
					game.gList.splice(n,1)
					break;
				}
			}			
		}
	}
	
	function draw(){

		
		
		//
		var grid = new Array()
		for( var x=0; x<game.xMax; x++ )grid[x] = new Array();
		
		for( var i=0; i<list.length; i++ ){
			var e = list[i]
			grid[e.px][e.py] = true;
		}
		for( var i=0; i<list.length; i++ ){
			var e = list[i]
			grid[e.px][e.py] = true;
		}
		//
		var dir = [
			{ x:0, y:-1, v:1 },
			{ x:1, y:0,  v:2 },
			{ x:0, y:1,  v:4 },
			{ x:-1, y:0, v:8 }
		]
		for( var i=0; i<list.length; i++ ){
			var e = list[i]
			var frame = 1
			for( var n=0; n<dir.length; n++ ){
				var d = dir[n];
				if( grid[e.px+d.x][e.py+d.y] ){
					frame += d.v
				}
			}
			e.skin.gotoAndStop(string(frame))
			Std.cast(e.skin).skin.gotoAndStop(string(frame))
		}		
		
	
	};	
	
	function kill(){
		for( var i=0; i<list.length; i++ ){
			list[i].group = null
		}
	}
	
//{
}


