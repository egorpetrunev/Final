class Obstacle {
  float posX;
  int w ;
  int h ;
  int type; 
  //------------------------------------------------------------------------------------------------------------------------------------------------------
  //constructor
  Obstacle(int t) {
    posX = width;
    type = t;
    switch(type) {
    case 0://small spike
      w = 40;
      h = 80;
      break;
    case 1://big spike
      w = 60;
      h = 120;
      break;
    case 2:
      w = 120;
      h = 80;
      break;
    }
  }

  //------------------------------------------------------------------------------------------------------------------------------------------------------
  void show() {
    fill(0);
    rectMode(CENTER);
    switch(type) {
    case 0:
      image(spikesmall, posX - spikesmall.width/2, height - groundHeight - spikesmall.height);
      break;
    case 1:
      image(spikebig, posX - spikebig.width/2, height - groundHeight - spikebig.height);
      break;
    case 2:
      image(spikesmallmany, posX - spikesmallmany.width/2, height - groundHeight - spikesmallmany.height);
      break;
    }
  }
  //------------------------------------------------------------------------------------------------------------------------------------------------------
  // move the obstacle
  void move(float speed) {
    posX -= speed;
  }
  //------------------------------------------------------------------------------------------------------------------------------------------------------
  //returns whether or not the player collides with this obstacle
  boolean collided(float playerX, float playerY, float playerWidth, float playerHeight) {

    float playerLeft = playerX - playerWidth/2;
    float playerRight = playerX + playerWidth/2;
    float thisLeft = posX - w/2 ;
    float thisRight = posX + w/2;

    if ((playerLeft<= thisRight && playerRight >= thisLeft ) || (thisLeft <= playerRight && thisRight >= playerLeft)) {
      float playerDown = playerY - playerHeight/2;
      float thisUp = h;
      if (playerDown <= thisUp) {
        return true;
      }
    }
    return false;
  }
}