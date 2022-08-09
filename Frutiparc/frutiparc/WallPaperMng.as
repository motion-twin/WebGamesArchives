class WallPaperMng{

   var mc:MovieClip;
   var width:Number;
   var height:Number;
   var mcl;

   var url:String;
   var bgColor:Number;
   var txtColor:Number;
   var pvAlpha:Number;

   function WallPaperMng(parentMc){
      //_global.debug("WallPaperMng constructor");
      parentMc.createEmptyMovieClip("wallpaper",Depths.wallPaper);

      this.mc = parentMc.wallpaper;
      this.mc.createEmptyMovieClip("bg",5);
      this.mc.createEmptyMovieClip("image",10);

      this.mc.dropBox = _global.desktop;
      this.mc.bg.dropBox = _global.desktop;
   }

   function loadWP(url,dataMisc){
      //_global.debug("WallPaperMng::loadWP("+url+")");
      this.mc.image.unloadMovie();
      this.mc.image._xscale = 100;
      this.mc.image._yscale = 100;

      if(url != undefined){
         this.mcl = new MovieClipLoader();
         this.mcl.addListener(this);
         this.mcl.loadClip(url,this.mc.image);
      }

      this.url = url;

      var arr = dataMisc.split(";");

      if(arr != undefined && arr.length >= 2){
         this.bgColor = Number("0x"+arr[0]);
         this.txtColor = Number("0x"+arr[1]);
      }else{
         this.bgColor = undefined;
         this.txtColor = undefined;
      }

      if(arr.length >= 3){
         this.pvAlpha = Number(arr[2]);
      }else{
         this.pvAlpha = 80;
      }

      this.displayBackground();

      _global.chatMng.onChangeWallpaper(this.url,this.pvAlpha);

      _global.desktop.displayIconList();
      
      if(url == undefined){
         _global.userPref.setAndSave("wallpaper","");
      }else{
         _global.userPref.setAndSave("wallpaper",url+"|"+dataMisc);
      }
//      _global.userPref.save();
   }

   function displayBackground(){
      if(this.bgColor == undefined){
         this.mc.bg.clear();
         return;
      }

      FEMC.initDraw(this.mc.bg);
      FEMC.drawSquare(this.mc.bg,{x: 0,y: 0,w: _global.mcw,h: _global.mch},this.bgColor);
   }

   function onLoadInit(){
      this.width = this.mc.image._width;
      this.height = this.mc.image._height;
      this.mc.image.dropBox = _global.desktop;
      this.onStageResize();
   }

   function show(){
      this.mc._visible = true;
   }

   function hide(){
      this.mc._visible = false;
   }

   function showImage(){
      this.mc.image._visible = true;
   }

   function hideImage(){
      this.mc.image._visible = false;
   }

   function onStageResize(){
      this.displayBackground();
   
      var available_width = _global.mcw - _global.main.cornerX;
      var available_height = _global.mch - _global.main.cornerY;

      if(this.width <= available_width && this.height <= available_height){
         var scale = 100;
         //this.mc.image._x = _global.main.cornerX + (available_width - this.width) / 2;
         //this.mc.image._y = _global.main.cornerY + (available_height - this.height) / 2;         
      }else{
         var width_ratio = available_width / this.width;
         var height_ratio = available_height / this.height;

         var scale = Math.min(width_ratio,height_ratio) * 100;
      }
      
      // scale image
      this.mc.image._xscale = scale;
      this.mc.image._yscale = scale;

      this.mc.image._x = _global.main.cornerX + (available_width - this.width * scale / 100) / 2;
      this.mc.image._y = _global.main.cornerY + (available_height - this.height * scale / 100) / 2;

   }
}
