class win.Chat extends win.Dialog{//}
	
	var flPenList:Boolean;
	var flUserList:Boolean;
	var flScreenList:Boolean;
	var leftIconList:Array;
	var mcLeftIconList:MovieClip;
	var lefIconListHMaxThin:Number;
	var lefIconListHMaxLarge:Number;
	var nbUser:Number;
	

	/*-----------------------------------------------------------------------
		Function: Chat()
		Constructeur
	 ------------------------------------------------------------------------*/		
	function Chat(){
		this.init();
	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		//clearInterval(_global.IntervalALaCon)	//DEBUG
		//this.iconLabel="chat"			//DEBUG
		
		//_root.test+="[winChat] init()\n"
		
		this.flPenList = false;
		this.flUserList = false;
		this.flScreenList = false;	
		
		super.init();

		// A virer
		this.nbUser = 2
		
		this.genLeftIconList()
		this.displayLeftIconList();
		this.endInit()	
	}

	/*-----------------------------------------------------------------------
		Function: genLeftIconList()
	 ------------------------------------------------------------------------*/	
	function genLeftIconList(){
		this.leftIconList = [
			{link:"butPush", param:{
					link:"butPushSmallPink",
					frame:3,
					outline:2,
					curve:4,
					tipId: "chat_bouille",
					buttonAction:{ 
						onPress:[{
							obj:this,
							method:"toggleScreenList"
						}]
					}
				}
			},
			{link:"butPush", param:{
					link:"butPushSmallPink",
					frame:2,
					outline:2,
					curve:4,
					tipId: "chat_userlist",
					buttonAction:{ 
						onPress:[{
							obj:this,
							method:"toggleUserList"
						}]
					}
				}
			},
			{link:"butPush", param:{
					link:"butPushSmallPink",
					frame:4,
					outline:2,
					curve:4,
					tipId: "chat_penlist",
					buttonAction:{ 
						onPress:[{
							obj:this,
							method:"togglePenList"
						}]
					}
				}
			},
			{link:"butPush", param:{
					link:"butPushSmallPink",
					frame:5,
					outline:2,
					curve:4,
					tipId: "chat_warning",
					buttonAction:{ 
						onPress:[{
							obj:this.box,
							method:"whining"
						}]
					}
				}
			}			
		];
			
		this.lefIconListHMaxThin =  4 + 24*this.leftIconList.length
		this.lefIconListHMaxLarge = 4 + 24*Math.ceil(this.leftIconList.length/4)
			
	}

	/*-----------------------------------------------------------------------
		Function: displayLeftIconList()
	 ------------------------------------------------------------------------*/
	function displayLeftIconList(){
		
		var margin = Standard.getMargin();
		margin.x.min = 8;
			
		var struct = Standard.getStruct();
		struct.limit="x";
		struct.x.size = 22;
		struct.y.size = 22;
		struct.x.space = 4;
		struct.y.space = 4;
		//struct.x.margin = 2;
		//struct.y.margin = 2;
		//struct.x.align = "center";
		
		var args = {
			list:leftIconList,
			struct:struct,
			flMask:true,
			//flExpand:true,
			mask:{flScrollable:false}
			//flTrace:true
		};
		
		var frame = {
			name:"leftIconListFrame",
			link:"basicIconList",
			type:"compo",
			min:{w:24,h:0},	//32
			margin:margin,
			args:args
		}
		
		this.mcLeftIconList = this.margin.left.newElement( frame )
		this.margin.left.bigFrame = this.margin.left.leftIconListFrame;
	}

	/*-----------------------------------------------------------------------
		Function: toggleUserList()
	 ------------------------------------------------------------------------*/
	function toggleUserList(){
		if(!this.flUserList){
			this.displayUserList();
		}else{
			this.margin.right.removeElement("userListFrame")
		}
		this.frameSet.update();
		this.flUserList=!this.flUserList;
	}
	
	/*-----------------------------------------------------------------------
		Function: displayUserList()
	 ------------------------------------------------------------------------*/	
	function displayUserList(){
		var m = Standard.getMargin();
		m.x.min = 12;
		var frame = {
			type:"compo",
			name:"userListFrame",
			link:"cpUserList",
			margin:m
		};
		this.margin.right.newElement(frame);
		this.margin.right.bigFrame = margin.right.userListFrame;	
	}
	
	/*-----------------------------------------------------------------------
		Function: toggleScreenList()
	 ------------------------------------------------------------------------*/
	function toggleScreenList(){
		if(!this.flScreenList){
			this.displayScreenList();
			this.margin.left.bigFrame = this.margin.left.screenList;
			this.mcLeftIconList.min.h = this.lefIconListHMaxLarge
		}else{
			this.margin.left.removeElement("screenList")
			this.margin.left.bigFrame = this.margin.left.leftIconListFrame;
			this.mcLeftIconList.min.h = this.lefIconListHMaxThin
		}
		
		//_root.test += "this.frLeftIconList.path.min.h  ----> "+this.frLeftIconList.path.min.h+"\n"
		
		this.frameSet.update();
		this.flScreenList=!this.flScreenList;
	}
	
	/*-----------------------------------------------------------------------
		Function: displayScreenList()
	 ------------------------------------------------------------------------*/	
	function displayScreenList(){
		var m = Standard.getMargin();
		m.x.min = 12;
		var frame = {
			type:"compo",
			name:"screenList",
			link:"cpScreenList",
			min:{w:100,h:200},
			win:this,
			margin:m
		};
		this.margin.left.newElement(frame);
			
	}
	
	/*-----------------------------------------------------------------------
		Function: togglePenList()
	 ------------------------------------------------------------------------*/	
	function togglePenList(){
		if(!this.flPenList){
			this.displayPenList();
		}else{
			this.main.removeElement("penFrame")
		}
		this.frameSet.update();
		this.flPenList=!this.flPenList;	
	}
	
	/*-----------------------------------------------------------------------
		Function: displayPenList()
	 ------------------------------------------------------------------------*/		
	function displayPenList(){

		var m = Standard.getMargin();
		m.x.min = 6;
		var frame = {
			type:"compo",
			name:"penFrame",
			link:"cpPenList",
			min:{w:120,h:48},
			win:this,
			margin:m
		};

		this.main.newElement(frame,1);
	}

	function setWallpaper( url, prc ){
		//_root.test += "[winChat] setWallpaper("+url+","+prc+")\n"
		this.main.fieldFrame.setWallpaper( url, prc )
	}
	
//{
}


