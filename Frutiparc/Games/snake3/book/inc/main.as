/*------------------------------------------------------------------------
    BOUCLE PRINCIPALE
 ------------------------------------------------------------------------*/
function main() {
  var move = false ;

  // Touches
  if ( Key.isDown(Key.RIGHT) ) {
    speed -= FLIP_SPEED ;
    move = true ;
  }
  if ( Key.isDown(Key.LEFT) ) {
    speed += FLIP_SPEED ;
    move = true ;
  }


  // Chute auto de la page
  if ( !move ) {
    if ( leftPage._rotation>=AUTOFALL_LIMIT )
      speed += FLIP_SPEED*0.5 ;
    if ( leftPage._rotation<AUTOFALL_LIMIT )
      speed -= FLIP_SPEED*0.5 ;
  }


  // Déplacement
  speed *= FRICTION ;
  leftPage._rotation += speed ;


  // Tourne vers la droite
  if ( speed>0 && leftPage._rotation > 90 ) {
    if (move) {
      if ( currentPage>0 ) {
        leftPage._rotation -=90 ;
        previousPage() ;
      }
      else {
        speed = 0 ;
        leftPage._rotation = 90 ;
      }
    }
    else {
      leftPage._rotation = 90 ;
      speed = 0 ;
    }
  }


  // Tourne vers la gauche
  if ( speed<0 && leftPage._rotation < 0 ) {
    if (move) {
      if ( currentPage<fruitList.length-1 ) {
        leftPage._rotation +=90 ;
        nextPage() ;
      }
      else {
        speed = 0 ;
        leftPage._rotation = 0 ;
      }
    }
    else {
      leftPage._rotation = 0 ;
      speed = 0 ;
    }
  }


  // Mise à jour graphique
  update() ;
}


/*------------------------------------------------------------------------
    INITIALISATION
 ------------------------------------------------------------------------*/
function init() {
  var dp=0 ;

  initDebug(0xffffff,"") ;

  this.attachMovie("bookBase","book",dp++) ;
  book._x = BOOK_X ;
  book._y = BOOK_Y ;

  this.attachMovie("page","rightPage",1000) ;
  rightPage._x = BOOK_X + PAGE_WIDTH*2 ;
  rightPage._y = BOOK_Y + PAGE_HEIGHT + PAGE_WIDTH ;
  rightPage._rotation = 0 ;
  rightPage.grad._alpha = 0 ;
  rightPage.gotoAndStop(2) ;

  this.attachMovie("page","leftPage",1001) ;
  leftPage._x = BOOK_X + PAGE_WIDTH ;
  leftPage._y = BOOK_Y + PAGE_HEIGHT + PAGE_WIDTH ;
  leftPage._rotation = 0 ;
  leftPage.grad._alpha = 0 ;
  leftPage.gotoAndStop(1) ;

  this.attachMovie("dropCorner","dropCorner",dp++) ;
  dropCorner._x = leftPage._x ;
  dropCorner._y = leftPage._y ;
  dropCorner._rotation = 0 ;
  dropCorner._alpha = 0 ;

  this.attachMovie("dropLarge","dropLarge",dp++) ;
  dropLarge._x = leftPage._x ;
  dropLarge._y = leftPage._y ;
  dropLarge._rotation = 0 ;
  dropLarge._alpha = 0 ;

  this.createEmptyMovieClip("leftMask",dp++) ;
  this.createEmptyMovieClip("rightMask",dp++) ;

  this.attachMovie("bookMask","cornerMask",dp++) ;
  cornerMask._x = BOOK_X ;
  cornerMask._y = BOOK_Y ;
  dropCorner.setMask(cornerMask) ;

  this.attachMovie("bookMask","largeMask",dp++) ;
  largeMask._x = BOOK_X ;
  largeMask._y = BOOK_Y ;
  dropLarge.setMask(largeMask) ;


  // Initialisation des éléments normalement fournis par Snake3
  fruitList = new Array(300) ;
  for ( var i=0;i< fruitList.length;i++ )
    if ( random(2)==0 )
      fruitList[i] = random(20) ;

  // Données de parcours du livre
  speed = 0 ;
  currentPage = 0 ;
  leftPage._rotation = 90 ;
  updatePages() ;

  update() ;
}



