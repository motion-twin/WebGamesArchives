/*---------------------------------------------
		
		FRUTIPARC windowComponent

---------------------------------------------*/

class cp.UserList extends Component{//}

	var slotList:Array;
	var slotSize:Number = 		18;
	var marginOutside:Number = 	5
	var marginInside:Number = 	5
	var index:Number = 		0;

	var slotMax:Number;
	var userTotal:Number;
	
	
	/*-----------------------------------------------------------------------
		Function: UserList()
		constructeur;
	 ------------------------------------------------------------------------*/	
	function UserList(){
		this.init();
		//_root.test+="userList init\n"
	}

	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/
	function init(){

		super.init();
		this.min={w:122,h:100};
		this.fix = {w:this.min.w};	

		this.slotList = new Array();
		
		// define the first value of userTotal
		this.userTotal = this.win.box.userList.length;
	}
	
	/*-----------------------------------------------------------------------
		Function: genContent()
	 ------------------------------------------------------------------------*/
	function genContent(){
		super.genContent()
		
		this.content.attachMovie("userListBackground","background",8)
		var mc = this.content.background
		
		mc.butTop.morphToButton();
		mc.butBot.morphToButton();
		
		mc.butTop.onFrutiPress = function (){
			this._parent._parent._parent.changeIndex(-1);
		}
		mc.butBot.onFrutiPress = function (){
			this._parent._parent._parent.changeIndex(1);
		}
	}

	/*-----------------------------------------------------------------------
		Function: updateSize()
	 ------------------------------------------------------------------------*/
	function updateSize(){
		
		super.updateSize();
		
		var u = 10;
		var mc = this.content.background;
		
		mc.top._y = 2*u + (this.marginInside-1);
		mc.rj._y = mc.top._y;
		mc.mid._y = 3*u + (this.marginInside-1);
		mc.mid._height = this.height-( 6*u + (this.marginInside-1)*2 )
		mc.bot._y = mc.mid._y + mc.mid._height + u
		mc.butBot._y = this.height - ( 2*u )
		

		var long = mc.mid._height
		this.slotMax = Math.floor(long/this.slotSize)
		this.recalIndex();
		this.win.box.userList.wantList(this,"setUserList", this.index, this.slotMax);

	}
	
	/*-----------------------------------------------------------------------
		Function: setUserList(list, userTotal)
	 ------------------------------------------------------------------------*/
	function setUserList(list, userTotal){
		//_root.test+="[cpUserList] setUserList() list.length("+list.length+")\n"
		
		var mc = this.content.background
		// Affiche les users dans les bons slots
		for(var i=0; i<list.length; i++){
			if(i>=this.slotList.length){
				// CREE un slot si besoin
				var bgFrame = 2-((i/2)==Math.round(i/2));
				this.content.attachMovie("userSlot","us"+i,200+i,{backgroundId:bgFrame,box: this.win.box,statusDspMode: "special"});
				var mc2 = this.content["us"+i];
				mc2._y = mc.mid._y + i*this.slotSize;
				this.slotList.push(mc2);				
			}
			this.slotList[i].setUser(list[i])
		}
		//casse les slot qui depassent
		while(this.slotList.length>list.length){
			var mc = this.slotList[this.slotList.length-1]
			mc.cleanUser()
			mc.removeMovieClip("")
			this.slotList.pop();
		}		
		this.userTotal = userTotal
	}	
		
	/*-----------------------------------------------------------------------
		Function: changeIndex(value)
	 ------------------------------------------------------------------------*/
	function changeIndex(value){
		this.index+=value
		this.recalIndex();
		this.win.box.userList.wantList(this,"setUserList", this.index, this.slotMax);
	}		
		
	/*-----------------------------------------------------------------------
		Function: recalIndex()
	 ------------------------------------------------------------------------*/
	function recalIndex(){
		this.index = Math.max(Math.min(this.index,this.userTotal-this.slotMax),0);
	}
		
	/*-----------------------------------------------------------------------
		Function: onKill()
	 ------------------------------------------------------------------------*/
	function onKill(){
		for(var i=0;i<this.slotMax;i++){
			this.slotList[i].cleanUser();
		}
	}
//{
}

























