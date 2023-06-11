class Player {
  float fitness;
  Genome brain;
  boolean replay = false;

  float unadjustedFitness;
  int lifespan = 0;//how long the player lived for fitness
  int bestScore =0;//stores the score achieved used for replay
  boolean dead;
  int score;
  int gen = 0;

  int genomeInputs = 7;
  int genomeOutputs = 3;

  float[] vision = new float[genomeInputs];//t he input array fed into the neuralNet 
  float[] decision = new float[genomeOutputs]; //the out put of the NN 
  //-------------------------------------
  float posY = 0;
  float velY = 0;
  float gravity =1.2;
  int runCount = -5;
  int size = 20;

  ArrayList<Obstacle> replayObstacles = new ArrayList<Obstacle>();
  ArrayList<bat> replaybats = new ArrayList<bat>();
  ArrayList<Integer> localObstacleHistory = new ArrayList<Integer>();
  ArrayList<Integer> localRandomAdditionHistory = new ArrayList<Integer>();
  int historyCounter = 0;
  int localObstacleTimer = 0;
  float localSpeed = 10;
  int localRandomAddition = 0;

  boolean duck= false;
  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  //constructor

  Player() {
    brain = new Genome(genomeInputs, genomeOutputs);
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  //show the 
  void show() {
    if (duck && posY == 0) {
      if (runCount < 0) {

        image(herolean, playerXpos - herolean.width/2, height - groundHeight - (posY + herolean.height));
      } else {

        image(herolean1, playerXpos - herolean1.width/2, height - groundHeight - (posY + herolean1.height));
      }
    } else
      if (posY ==0) {
        if (runCount < 0) {
          image(herorun1, playerXpos - herorun1.width/2, height - groundHeight - (posY + herorun1.height));
        } else {
          image(herorun2, playerXpos - herorun2.width/2, height - groundHeight - (posY + herorun2.height));
        }
      } else {
        image(herojump, playerXpos - herojump.width/2, height - groundHeight - (posY + herojump.height));
      }
    runCount++;
    if (runCount > 5) {
      runCount = -5;
    }
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  void incrementCounters() {
    lifespan++;
    if (lifespan % 3 ==0) {
      score+=1;
    }
  }


  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  //checks for collisions and if this is a replay move all the obstacles
  void move() {
    posY += velY;
    if (posY >0) {
      velY -= gravity;
    } else {
      velY = 0;
      posY = 0;
    }

    if (!replay) {

      for (int i = 0; i< obstacles.size(); i++) {
        if (obstacles.get(i).collided(playerXpos, posY +herorun1.height/2, herorun1.width*0.5, herorun1.height)) {
          dead = true;
        }
      }

      for (int i = 0; i< bats.size(); i++) {
        if (duck && posY ==0) {
          if (bats.get(i).collided(playerXpos, posY + herolean.height/2, herolean.width*0.8, herolean.height)) {
            dead = true;
          }
        } else {
          if (bats.get(i).collided(playerXpos, posY +herorun1.height/2, herorun1.width*0.5, herorun1.height)) {
            dead = true;
          }
        }
      }
    } else {//if replayign then move local obstacles
      for (int i = 0; i< replayObstacles.size(); i++) {
        if (replayObstacles.get(i).collided(playerXpos, posY +herorun1.height/2, herorun1.width*0.5, herorun1.height)) {
          dead = true;
        }
      }


      for (int i = 0; i< replaybats.size(); i++) {
        if (duck && posY ==0) {
          if (replaybats.get(i).collided(playerXpos, posY + herolean.height/2, herolean.width*0.8, herolean.height)) {
            dead = true;
          }
        } else {
          if (replaybats.get(i).collided(playerXpos, posY +herorun1.height/2, herorun1.width*0.5, herorun1.height)) {
            dead = true;
          }
        }
      }
    }
  }


  //---------------------------------------------------------------------------------------------------------------------------------------------------------
//what could this do????
  void jump(boolean bigJump) {
    if (posY ==0) {
      if (bigJump) {
        gravity = 1;
        velY = 20;
      } else {
        gravity = 1.2;
        velY = 16;
      }
    }
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  //if parameter is true and is in the air increase gravity
  void ducking(boolean isDucking) {
    if (posY != 0 && isDucking) {
      gravity = 3;
    }
    duck = isDucking;
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  //called every frame
  void update() {
    incrementCounters();
    move();
  }
  //----------------------------------------------------------------------------------------------------------------------------------------------------------
  //get inputs for Neural network
  void look() {
    if (!replay) {
      float temp = 0;
      float min = 10000;
      int minIndex = -1;
      boolean berd = false; 
      for (int i = 0; i< obstacles.size(); i++) {
        if (obstacles.get(i).posX + obstacles.get(i).w/2 - (playerXpos - herorun1.width/2) < min &&  obstacles.get(i).posX + obstacles.get(i).w/2 - (playerXpos - herorun1.width/2) > 0) {//if the distance between the left of the player and the right of the obstacle is the least
          min = obstacles.get(i).posX + obstacles.get(i).w/2 - (playerXpos - herorun1.width/2);
          minIndex = i;
        }
      }

      for (int i = 0; i< bats.size(); i++) {
        if (bats.get(i).posX + bats.get(i).w/2 - (playerXpos - herorun1.width/2) < min &&  bats.get(i).posX + bats.get(i).w/2 - (playerXpos - herorun1.width/2) > 0) {//if the distance between the left of the player and the right of the obstacle is the least
          min = bats.get(i).posX + bats.get(i).w/2 - (playerXpos - herorun1.width/2);
          minIndex = i;
          berd = true;
        }
      }
      vision[4] = speed;
      vision[5] = posY;


      if (minIndex == -1) {//if there are no obstacles
        vision[0] = 0; 
        vision[1] = 0;
        vision[2] = 0;
        vision[3] = 0;
        vision[6] = 0;
      } else {

        vision[0] = 1.0/(min/10.0);
        if (berd) {
          vision[1] = bats.get(minIndex).h;
          vision[2] = bats.get(minIndex).w;
          if (bats.get(minIndex).typeOfbat == 0) {
            vision[3] = 0;
          } else {
            vision[3] = bats.get(minIndex).posY;
          }
        } else {
          vision[1] = obstacles.get(minIndex).h;
          vision[2] = obstacles.get(minIndex).w;
          vision[3] = 0;
        }




        //vision 6 is the gap between the this obstacle and the next one
        int bestIndex = minIndex;
        float closestDist = min;
        min = 10000;
        minIndex = -1;
        for (int i = 0; i< obstacles.size(); i++) {
          if ((berd || i != bestIndex) && obstacles.get(i).posX + obstacles.get(i).w/2 - (playerXpos - herorun1.width/2) < min &&  obstacles.get(i).posX + obstacles.get(i).w/2 - (playerXpos - herorun1.width/2) > 0) {//if the distance between the left of the player and the right of the obstacle is the least
            min = obstacles.get(i).posX + obstacles.get(i).w/2 - (playerXpos - herorun1.width/2);
            minIndex = i;
          }
        }

        for (int i = 0; i< bats.size(); i++) {
          if ((!berd || i != bestIndex) && bats.get(i).posX + bats.get(i).w/2 - (playerXpos - herorun1.width/2) < min &&  bats.get(i).posX + bats.get(i).w/2 - (playerXpos - herorun1.width/2) > 0) {//if the distance between the left of the player and the right of the obstacle is the least
            min = bats.get(i).posX + bats.get(i).w/2 - (playerXpos - herorun1.width/2);
            minIndex = i;
          }
        }

        if (minIndex == -1) {//if there is only one obejct on the screen
          vision[6] = 0;
        } else {
          vision[6] = 1/(min - closestDist);
        }
      }
    } else {//if replaying then use local shit
      float temp = 0;
      float min = 10000;
      int minIndex = -1;
      boolean berd = false; 
      for (int i = 0; i< replayObstacles.size(); i++) {
        if (replayObstacles.get(i).posX + replayObstacles.get(i).w/2 - (playerXpos - herorun1.width/2) < min &&  replayObstacles.get(i).posX + replayObstacles.get(i).w/2 - (playerXpos - herorun1.width/2) > 0) {//if the distance between the left of the player and the right of the obstacle is the least
          min = replayObstacles.get(i).posX + replayObstacles.get(i).w/2 - (playerXpos - herorun1.width/2);
          minIndex = i;
        }
      }

      for (int i = 0; i< replaybats.size(); i++) {
        if (replaybats.get(i).posX + replaybats.get(i).w/2 - (playerXpos - herorun1.width/2) < min &&  replaybats.get(i).posX + replaybats.get(i).w/2 - (playerXpos - herorun1.width/2) > 0) {//if the distance between the left of the player and the right of the obstacle is the least
          min = replaybats.get(i).posX + replaybats.get(i).w/2 - (playerXpos - herorun1.width/2);
          minIndex = i;
          berd = true;
        }
      }
      vision[4] = localSpeed;
      vision[5] = posY;


      if (minIndex == -1) {//if there are no replayObstacles
        vision[0] = 0; 
        vision[1] = 0;
        vision[2] = 0;
        vision[3] = 0;
        vision[6] = 0;
      } else {

        vision[0] = 1.0/(min/10.0);
        if (berd) {
          vision[1] = replaybats.get(minIndex).h;
          vision[2] = replaybats.get(minIndex).w;
          if (replaybats.get(minIndex).typeOfbat == 0) {
            vision[3] = 0;
          } else {
            vision[3] = replaybats.get(minIndex).posY;
          }
        } else {
          vision[1] = replayObstacles.get(minIndex).h;
          vision[2] = replayObstacles.get(minIndex).w;
          vision[3] = 0;
        }




        //vision 6 is the gap between the this obstacle and the next one
        int bestIndex = minIndex;
        float closestDist = min;
        min = 10000;
        minIndex = -1;
        for (int i = 0; i< replayObstacles.size(); i++) {
          if ((berd || i != bestIndex) && replayObstacles.get(i).posX + replayObstacles.get(i).w/2 - (playerXpos - herorun1.width/2) < min &&  replayObstacles.get(i).posX + replayObstacles.get(i).w/2 - (playerXpos - herorun1.width/2) > 0) {//if the distance between the left of the player and the right of the obstacle is the least
            min = replayObstacles.get(i).posX + replayObstacles.get(i).w/2 - (playerXpos - herorun1.width/2);
            minIndex = i;
          }
        }

        for (int i = 0; i< replaybats.size(); i++) {
          if ((!berd || i != bestIndex) && replaybats.get(i).posX + replaybats.get(i).w/2 - (playerXpos - herorun1.width/2) < min &&  replaybats.get(i).posX + replaybats.get(i).w/2 - (playerXpos - herorun1.width/2) > 0) {//if the distance between the left of the player and the right of the obstacle is the least
            min = replaybats.get(i).posX + replaybats.get(i).w/2 - (playerXpos - herorun1.width/2);
            minIndex = i;
          }
        }

        if (minIndex == -1) {//if there is only one obejct on the screen
          vision[6] = 0;
        } else {
          vision[6] = 1/(min - closestDist);
        }
      }
    }
  }






  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  //gets the output of the brain then converts them to actions
  void think() {

    float max = 0;
    int maxIndex = 0;
    //get the output of the neural network
    decision = brain.feedForward(vision);

    for (int i = 0; i < decision.length; i++) {
      if (decision[i] > max) {
        max = decision[i];
        maxIndex = i;
      }
    }

    if (max < 0.7) {
      ducking(false);
      return;
    }

    switch(maxIndex) {
    case 0:
      jump(false);
      break;
    case 1:
      jump(true);
      break;
    case 2:
      ducking(true);
      break;
    }
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //returns a clone of this player with the same brian
  Player clone() {
    Player clone = new Player();
    clone.brain = brain.clone();
    clone.fitness = fitness;
    clone.brain.generateNetwork(); 
    clone.gen = gen;
    clone.bestScore = score;
    return clone;
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //since there is some randomness in games sometimes when we want to replay the game we need to remove that randomness
  //this fuction does that

  Player cloneForReplay() {
    Player clone = new Player();
    clone.brain = brain.clone();
    clone.fitness = fitness;
    clone.brain.generateNetwork();
    clone.gen = gen;
    clone.bestScore = score;
    clone.replay = true;
    if (replay) {
      clone.localObstacleHistory = (ArrayList)localObstacleHistory.clone();
      clone.localRandomAdditionHistory = (ArrayList)localRandomAdditionHistory.clone();
    } else {
      clone.localObstacleHistory = (ArrayList)obstacleHistory.clone();
      clone.localRandomAdditionHistory = (ArrayList)randomAdditionHistory.clone();
    }

    return clone;
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  //fot Genetic algorithm
  void calculateFitness() {
    fitness = score*score;
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  Player crossover(Player parent2) {
    Player child = new Player();
    child.brain = brain.crossover(parent2.brain);
    child.brain.generateNetwork();
    return child;
  }
  //--------------------------------------------------------------------------------------------------------------------------------------------------------
  //if replaying then the has local obstacles
  void updateLocalObstacles() {
    localObstacleTimer ++;
    localSpeed += 0.002;
    if (localObstacleTimer > minimumTimeBetweenObstacles + localRandomAddition) {
      addLocalObstacle();
    }
    groundCounter ++;
    if (groundCounter > 10) {
      groundCounter =0;
      grounds.add(new Ground());
    }

    moveLocalObstacles();
    showLocalObstacles();
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  void moveLocalObstacles() {
    for (int i = 0; i< replayObstacles.size(); i++) {
      replayObstacles.get(i).move(localSpeed);
      if (replayObstacles.get(i).posX < -100) {
        replayObstacles.remove(i);
        i--;
      }
    }

    for (int i = 0; i< replaybats.size(); i++) {
      replaybats.get(i).move(localSpeed);
      if (replaybats.get(i).posX < -100) {
        replaybats.remove(i);
        i--;
      }
    }
    for (int i = 0; i < grounds.size(); i++) {
      grounds.get(i).move(localSpeed);
      if (grounds.get(i).posX < -100) {
        grounds.remove(i);
        i--;
      }
    }
  }
  //------------------------------------------------------------------------------------------------------------------------------------------------------------
  void addLocalObstacle() {
    int tempInt = localObstacleHistory.get(historyCounter);
    localRandomAddition = localRandomAdditionHistory.get(historyCounter);
    historyCounter ++;
    if (tempInt < 3) {
      replaybats.add(new bat(tempInt));
    } else {
      replayObstacles.add(new Obstacle(tempInt -3));
    }
    localObstacleTimer = 0;
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  void showLocalObstacles() {
    for (int i = 0; i< grounds.size(); i++) {
      grounds.get(i).show();
    }
    for (int i = 0; i< replayObstacles.size(); i++) {
      replayObstacles.get(i).show();
    }

    for (int i = 0; i< replaybats.size(); i++) {
      replaybats.get(i).show();
    }
  }
}