import java.util.HashMap;
import java.util.*;
import java.awt.*;
import processing.sound.*;
SoundFile sound;
String[] ambientMusic = {"MUSIC_GAME_DANNY.mp3", "MUSIC_GAME_MINECRAFT.mp3", "MUSIC_GAME_SUBWOOFER LULLABY.mp3", "MUSIC_GAME_SWEDEN.mp3", "MUSIC_GAME_WET HANDS.mp3"};
String[] creativeMusic = {"MUSIC_GAME_CREATIVE_ARIA MATH.mp3", "MUSIC_GAME_CREATIVE_BIOME FEST.mp3", "MUSIC_GAME_CREATIVE_TASWELL.mp3"};
String[][] stepPath = {
  {"STEP_GRASS1.mp3", "STEP_GRASS2.mp3", "STEP_GRASS3.mp3", "STEP_GRASS4.mp3", "STEP_GRASS5.mp3", "STEP_GRASS6.mp3"},
  {"STEP_GRASS1.mp3", "STEP_GRASS2.mp3", "STEP_GRASS3.mp3", "STEP_GRASS4.mp3", "STEP_GRASS5.mp3", "STEP_GRASS6.mp3"},
  {"STEP_STONE1.mp3", "STEP_STONE2.mp3", "STEP_STONE3.mp3", "STEP_STONE4.mp3", "STEP_STONE5.mp3", "STEP_STONE6.mp3"},
  {"STEP_WOOD1.mp3", "STEP_WOOD2.mp3", "STEP_WOOD3.mp3", "STEP_WOOD4.mp3", "STEP_WOOD5.mp3", "STEP_WOOD6.mp3"},
  {},
  {},
  {},
  {},
  {},
  {}};
SoundFile[][] stepSounds;
int soundTimer = 0;
int swimTimer = 0;
String[][] breakPath = {
  {"DIG_GRASS1.mp3", "DIG_GRASS2.mp3", "DIG_GRASS3.mp3", "DIG_GRASS4.mp3"},
  {"DIG_GRASS1.mp3", "DIG_GRASS2.mp3", "DIG_GRASS3.mp3", "DIG_GRASS4.mp3"},
  {"DIG_STONE1.mp3", "DIG_STONE2.mp3", "DIG_STONE3.mp3", "DIG_STONE4.mp3"},
  {},
  {"DIG_WOOD1.mp3", "DIG_WOOD2.mp3", "DIG_WOOD3.mp3", "DIG_WOOD4.mp3"},
  {},
  {"DIG_WOOD1.mp3", "DIG_WOOD2.mp3", "DIG_WOOD3.mp3", "DIG_WOOD4.mp3"},
  {"DIG_WOOD1.mp3", "DIG_WOOD2.mp3", "DIG_WOOD3.mp3", "DIG_WOOD4.mp3"},
  {"DIG_WOOD1.mp3", "DIG_WOOD2.mp3", "DIG_WOOD3.mp3", "DIG_WOOD4.mp3"},
  {"DIG_WOOD1.mp3", "DIG_WOOD2.mp3", "DIG_WOOD3.mp3", "DIG_WOOD4.mp3"}};
SoundFile[][] breakSounds;

PImage[] destroy = new PImage[10];

String[] swimPath = {"LIQUID_SWIM1.mp3", "LIQUID_SWIM2.mp3", "LIQUID_SWIM3.mp3", "LIQUID_SWIM4.mp3", "LIQUID_SWIM5.mp3"};
SoundFile[] swimSounds;

float volume = 1;

boolean[] transparent = {false, false, false, true, false, true, true, true, true, true};
PImage atlas;

int blockSelected = 1;

Block destroyBlock = null;
int destroyStage = 0;

int seed = 2500;
ArrayList<Chunk> chunks = new ArrayList();
HashMap<Long, Chunk> chunkMap = new HashMap();

boolean[] keys = new boolean[256];

PVector playerPos = new PVector(0, 0, 0);
PVector cameraPos = new PVector(playerPos.x, playerPos.y, playerPos.z);
PVector vel = new PVector(0, 0, 0);
//azimuth(yaw), elevation(pitch)
PVector dir = new PVector(0.01, -1, 0);
float yaw = 0, pitch = PI/2;

PVector mouse = new PVector(-1, -1);

int mouseTime = 0;

boolean controlDown = false;
boolean shiftDown = false;

int blockOn = -1;
boolean inWater = false;

boolean playingAmbient = true;

boolean sprint = false;

boolean fly = false;
long spaceTime = 0;

float defaultFov = PI*0.45;
float fov = defaultFov;

float player_height = 29;
float camera_height = 26;
float player_width = 10;
float height_above = player_height-camera_height;

final int cubeSize = 16;
final int blockSize = cubeSize;
int worldBottom = -0*cubeSize;
int chunkSize = 16;
int chunkWidth = chunkSize*blockSize;
final float defaultG = 0.12;
float gravity = defaultG;
float defaultSpeed = 0.25;
float speed = defaultSpeed;
final float defaultJump = 2.1;
float jump = defaultJump;

int renderDist = 1536/2;

boolean thirdPerson = false;
PVector[] hitbox = {
  new PVector(-player_width/2+1, -camera_height+1, -player_width/2+1),
  new PVector(-player_width/2+1, -camera_height+1, player_width/2-1),
  new PVector( player_width/2-1, -camera_height+1, -player_width/2+1),
  new PVector( player_width/2-1, -camera_height+1, player_width/2-1),

  new PVector(-player_width/2+1, height_above-1, -player_width/2+1),
  new PVector(-player_width/2+1, height_above-1, player_width/2-1),
  new PVector( player_width/2-1, height_above-1, -player_width/2+1),
  new PVector( player_width/2-1, height_above-1, player_width/2-1),

  new PVector(-player_width/2+1, -camera_height+player_height/2, -player_width/2+1),
  new PVector(-player_width/2+1, -camera_height+player_height/2, player_width/2-1),
  new PVector( player_width/2-1, -camera_height+player_height/2, -player_width/2+1),
  new PVector( player_width/2-1, -camera_height+player_height/2, player_width/2-1)
};
int[] topbox = {4, 5, 6, 7};
int[] bottombox = {0, 1, 2, 3};
int[] posxbox = {2, 3, 6, 7, 10, 11};
int[] negxbox = {0, 1, 4, 5, 8, 9};
int[] poszbox = {1, 3, 5, 7, 9, 11};
int[] negzbox = {0, 2, 4, 6, 8, 10};

PImage hotbar;
PImage hotbarselector;

Robot robot;
boolean mouseLock = false;
int handTime = 0;

int beginTime = 0;
PrintWriter output;
String[] operations;
void settings() {
  fullScreen(P3D);
  //size(1710, 1000, P3D);
  noSmooth();
}
void exit() {
  output.flush();
  output.close();
  super.exit();
}
void setup() {
  try {
    robot = new Robot();
  }
  catch(Exception e) {
    println("ERROR CREATING ROBOT");
  }
  operations = loadStrings("save_file.txt");
  output = createWriter("save_file.txt");
  for(int i = 0; i < operations.length; i++){
    output.println(operations[i]);
  }
  output.flush();
  noStroke();
  hotbar = loadImage("hotbar.png");
  hotbarselector = loadImage("hotbarselector.png");
  sound = new SoundFile(this, ambientMusic[(int)(Math.random()*ambientMusic.length)]);
  sound.play();
  stepSounds = new SoundFile[stepPath.length][];
  for (int i = 0; i < stepPath.length; i++) {
    stepSounds[i] = new SoundFile[stepPath[i].length];
    for (int j = 0; j < stepPath[i].length; j++) {
      stepSounds[i][j] = new SoundFile(this, stepPath[i][j]);
    }
  }
  for (int i = 0; i < 10; i++) {
    destroy[i] = loadImage("destroy_stage_"+i+".png");
  }
  breakSounds = new SoundFile[breakPath.length][];
  for (int i = 0; i < breakPath.length; i++) {
    breakSounds[i] = new SoundFile[breakPath[i].length];
    for (int j = 0; j < breakPath[i].length; j++) {
      breakSounds[i][j] = new SoundFile(this, breakPath[i][j]);
    }
  }

  swimSounds = new SoundFile[swimPath.length];
  for (int i = 0; i < swimPath.length; i++) {
    swimSounds[i] = new SoundFile(this, swimPath[i]);
  }
  ((PGraphicsOpenGL)getGraphics()).textureSampling(2);
  hint(DISABLE_TEXTURE_MIPMAPS);
  atlas = loadImage("atlas.png");
  frameRate(40);
  fill(255, 255);
  stroke(0);
  strokeWeight(5);
  lights();

  playerPos.y = 4*cubeSize+camera_height;

  Chunk chunk = new Chunk(new PVector(0, 0, 0), seed);
  chunks.add(chunk);
  chunkMap.put(vectorHash(chunk.pos), chunk);
  for (Chunk c : chunks) {
    c.update();
  }
}
void draw() {
  if (fly)
    defaultSpeed = 0.6;
  else
    defaultSpeed = 0.25;
  if (sprint) {
    defaultSpeed *= 1.2;
    fov = 0.7*(fov-defaultFov*6/5) + defaultFov*6/5;
  } else {
    fov = 0.7*(fov-defaultFov) + defaultFov;
  }
  speed = defaultSpeed * 60/frameRate;
  jump = defaultJump * 60/frameRate;
  gravity = defaultG * 3600/frameRate/frameRate;


  if (!mouseLock) {
    if (mouse.x != -1) {
      mouseTime ++;
      yaw -= (mouseX-mouse.x)/300;
      pitch += (mouseY-mouse.y)/300;
      if (mouseX-mouse.x != 0 || mouseY-mouse.y != 0) {
        mouseTime = 100;
      }
      mouse.x = mouseX;
      mouse.y = mouseY;
    }
  } else {
    yaw -= (1.0*mouseX-width/2)/300;
    pitch += (1.0*mouseY-height/2)/300;
    //robot.mouseMove(854, 567);
    //robotCenterX = mouseX;
    //robotCenterY = mouseY;
  }
  if (pitch < 0.01) {
    pitch = 0.01;
  }
  if (pitch > PI-0.01) {
    pitch = (float)PI-0.01;
  }
  dir.x = sin(pitch) * cos(yaw);
  dir.y = cos(pitch);
  dir.z = sin(pitch) * sin(yaw);
  if (blockOn == -1 && !fly)
    vel.y -= gravity;
  vel.x *= 0.8;
  vel.z *= 0.8;
  if (fly)
    vel.y *= 0.8;
  if (inWater && !fly) {
    vel.x *= 0.8;
    vel.z *= 0.8;
    vel.y *= 0.8;
  }

  playerPos.y += vel.y;
  blockOn = -1;
  inWater = false;
  for (int i : bottombox) {
    PVector hit = PVector.add(playerPos, hitbox[i]);
    hit.y--;
    if (getBlock(hit) != null) {
      if (getBlock(hit).blockType > 4) {
        continue;
      }
      playerPos.y = round(hit).y+cubeSize/2+camera_height;
      if (vel.y < 0)
        vel.y = 0;
      blockOn = getBlock(hit).blockType;
    }
  }
  if (blockOn != -1)
    inWater = false;
  for (int i : topbox) {
    PVector hit = PVector.add(playerPos, hitbox[i]);
    hit.y++;
    if (getBlock(hit) != null && getBlock(hit).blockType < 5) {
      playerPos.y = round(hit).y-cubeSize/2-height_above;
      if (vel.y > 0)
        vel.y = 0;
    }
  }
  playerPos.x += vel.x;
  for (int i : posxbox) {
    PVector hit = PVector.add(playerPos, hitbox[i]);
    hit.x ++;
    if (getBlock(hit) != null && getBlock(hit).blockType < 5) {
      playerPos.x = round(hit).x-cubeSize/2-player_width/2;
      if (vel.x > 0)
        vel.x = 0;
    }
  }
  for (int i : negxbox) {
    PVector hit = PVector.add(playerPos, hitbox[i]);
    hit.x --;
    if (getBlock(hit) != null && getBlock(hit).blockType < 5) {
      playerPos.x = round(hit).x+cubeSize/2+player_width/2;
      if (vel.x < 0)
        vel.x = 0;
    }
  }
  playerPos.z += vel.z;
  for (int i : poszbox) {
    PVector hit = PVector.add(playerPos, hitbox[i]);
    hit.z ++;
    if (getBlock(hit) != null && getBlock(hit).blockType < 5) {
      playerPos.z = round(hit).z-cubeSize/2-player_width/2;
      if (vel.z > 0)
        vel.z = 0;
    }
  }
  for (int i : negzbox) {
    PVector hit = PVector.add(playerPos, hitbox[i]);
    hit.z --;
    if (getBlock(hit) != null && getBlock(hit).blockType < 5) {
      playerPos.z = round(hit).z+cubeSize/2+player_width/2;
      if (vel.z < 0)
        vel.z = 0;
    }
  }
  //begin drawing
  PVector look = PVector.add(playerPos, dir);

  if (!thirdPerson) {
    cameraPos.x = playerPos.x;
    cameraPos.y = playerPos.y;
    cameraPos.z = playerPos.z;
    camera(
      cameraPos.x,
      cameraPos.y,
      cameraPos.z,
      look.x,
      look.y,
      look.z,
      0,
      -1,
      0
      );
  } else {
    cameraPos.x = playerPos.x;
    cameraPos.y = playerPos.y;
    cameraPos.z = playerPos.z;
    int dist = 0;
    while (!(getBlock(round(cameraPos)) != null) && dist < 32) {
      cameraPos.sub(dir);
      dist++;
    }
    cameraPos.add(dir);
    camera(
      cameraPos.x,
      cameraPos.y,
      cameraPos.z,
      look.x,
      look.y,
      look.z,
      0,
      -1,
      0
      );
  }
  perspective(fov, (float) width / height, 0.1, 1000000);

  background(180, 210, 250);
  fill(128);
  tint(128);
  ambientLight(196, 196, 196);
  directionalLight(196, 196, 196, -0.5, -1, -0.3);
  createNewChunks();

  drawAllBlocks();
  highlightFace();
  if (thirdPerson) {
    drawThirdPersonFrame();
  }


  keyActions();

  if (mouseLock) {
    noCursor();
    robot.mouseMove(width/2, height/2);
    mouseX = width/2;
    mouseY = height/2;
  } else {
    mouseLock = true;
  }




  playSounds();

  handTime ++;
  if (mousePressed && mouseButton == RIGHT && handTime > frameRate/6) {
    handTime = 0;
    if (placeBlock())
      handTime = 0;
  }
  if (mousePressed && mouseButton == LEFT && handTime > frameRate/6) {
    PVector[] m = mouseBlock();
    if (m != null) {

      PVector v = mouseBlock()[0];
      if (getBlock(v) == destroyBlock && v.y != worldBottom) {
        destroyStage = 10;
        if (destroyStage >= destroy.length) {
          if (breakBlock())
            handTime = 0;
        }
      } else {
        destroyBlock = getBlock(v);
      }
    } else {
      destroyStage = 0;
      destroyBlock = null;
    }
  } else {
    destroyStage = 0;
    destroyBlock = null;
  }

  noLights();
  imageMode(CENTER);
  hint(DISABLE_DEPTH_TEST);
  fill(255, 255);
  tint(255, 255);
  camera();
  ortho();

  int hotbarheight = hotbar.height*width/3/hotbar.width;
  image(hotbar, width/2, height-hotbarheight/2-10, width/3, hotbarheight);

  image(hotbarselector, width/2+(blockSelected-5)*hotbarheight*40.45/44, height-hotbarheight/2-10, hotbarheight*48/44, hotbarheight*48/44);
  for (int i = 1; i <= 9; i++) {
    if(i == 5){
      image(atlas.get(4*16, 32, 16, 16), width/2+(i-5)*hotbarheight*40.45/44, height-hotbarheight/2-10, hotbarheight*30/44, hotbarheight*30/44);
    }
    else
    image(atlas.get(i*16, 16, 16, 16), width/2+(i-5)*hotbarheight*40.45/44, height-hotbarheight/2-10, hotbarheight*30/44, hotbarheight*30/44);
  }
  imageMode(CORNER);
  if (mouseLock) {
    strokeWeight(3);
    stroke(196, 128);
    line(width/2-15, height/2, width/2+15, height/2);
    line(width/2, height/2-15, width/2, height/2+15);
    stroke(0);
  }
  hint(ENABLE_DEPTH_TEST);
}
void keyActions() {
  //------------------------------------------------- move from key input
  PVector moveDir = new PVector(dir.x, 0, dir.z);
  moveDir.normalize();
  moveDir.mult(speed);
  if (keys['a']) {
    vel.z += moveDir.x;
    vel.x -= moveDir.z;
  }
  if (keys['d']) {
    vel.z -= moveDir.x;
    vel.x +=  moveDir.z;
  }
  if (keys['w']) {
    vel.x += moveDir.x;
    vel.z += moveDir.z;
  }
  if (keys['s']) {
    vel.x -= moveDir.x;
    vel.z -=  moveDir.z;
  }
  for (int i = 1; i < 10; i++) {
    if (keys['0'+i]) {
      keys['0'+i] = false;
      blockSelected = i;
    }
  }
  //------------------------------------------------- jump/switch perspective
  if (keys[' '] && blockOn != -1 && !fly && !inWater) {
    vel.y = jump;
  }
  if (keys[' '] && fly) {
    vel.y += speed;
  }
  if (keys[' '] && !fly && inWater) {
    vel.y += gravity*4;
  }
  if (keys['v']) {
    thirdPerson = !thirdPerson;
    keys['v'] = false;
  }
  if (shiftDown && fly) {
    vel.y -= speed;
  }
  if (controlDown && (keys['w'] || keys['s'] || keys['a'] || keys['d'])) {
    sprint = true;
  }
  if (!controlDown && !(keys['w'] || keys['s'] || keys['a'] || keys['d'])) {
    sprint = false;
  }
}
//-------------------------------------------------------- highlight face selected
void highlightFace()
{
  PVector[] loc = mouseBlock();
  if (loc != null) {
    hint(DISABLE_DEPTH_TEST);
    Block b1 = new Block(loc[0]);
    Block b2 = new Block(loc[1]);
    if (b1.cover(b2) != -1) {
      int side = b1.cover(b2);
      pushMatrix();
      translate(b1.pos.x, b1.pos.y, b1.pos.z);
      fill(255, 255, 255, 64);
      //pos x side
      if (side == 0) {
        pushMatrix();
        translate(cubeSize/2+.1, 0, 0);
        rotateY(PI/2);
        rect(-cubeSize/2, -cubeSize/2, cubeSize, cubeSize);
        popMatrix();
      }
      //neg x side
      if (side == 1) {
        pushMatrix();
        translate(-cubeSize/2-.1, 0, 0);
        rotateY(PI/2);
        rect(-cubeSize/2, -cubeSize/2, cubeSize, cubeSize);
        popMatrix();
      }


      //top side
      if (side == 4) {
        pushMatrix();
        translate(0, cubeSize/2+.1, 0);
        rotateX(PI/2);
        rect(-cubeSize/2, -cubeSize/2, cubeSize, cubeSize);
        popMatrix();
      }
      //bottom side
      if (side == 5) {
        pushMatrix();
        translate(0, -cubeSize/2-.1, 0);
        rotateX(PI/2);
        rect(-cubeSize/2, -cubeSize/2, cubeSize, cubeSize);
        popMatrix();
      }

      //pos z side
      if (side == 2) {
        pushMatrix();
        translate(0, 0, cubeSize/2+.1);
        rect(-cubeSize/2, -cubeSize/2, cubeSize, cubeSize);
        popMatrix();
      }
      //neg z side
      if (side == 3) {
        pushMatrix();
        translate(0, 0, -cubeSize/2-.1);
        rect(-cubeSize/2, -cubeSize/2, cubeSize, cubeSize);
        popMatrix();
      }
      popMatrix();
    }
    hint(ENABLE_DEPTH_TEST);
  }
}
void drawThirdPersonFrame() {
  pushMatrix();
  translate(playerPos.x, playerPos.y-camera_height+player_height/2, playerPos.z);
  strokeWeight(6);
  //vertical lines
  line(-player_width/2, -player_height/2, -player_width/2, -player_width/2, player_height/2, -player_width/2);
  line( player_width/2, -player_height/2, -player_width/2, player_width/2, player_height/2, -player_width/2);
  line(-player_width/2, -player_height/2, player_width/2, -player_width/2, player_height/2, player_width/2);
  line( player_width/2, -player_height/2, player_width/2, player_width/2, player_height/2, player_width/2);

  //x lines
  line(-player_width/2, -player_height/2, -player_width/2, player_width/2, -player_height/2, -player_width/2);
  line(-player_width/2, -player_height/2, player_width/2, player_width/2, -player_height/2, player_width/2);
  line(-player_width/2, player_height/2, -player_width/2, player_width/2, player_height/2, -player_width/2);
  line(-player_width/2, player_height/2, player_width/2, player_width/2, player_height/2, player_width/2);

  //z lines
  line(-player_width/2, -player_height/2, -player_width/2, -player_width/2, -player_height/2, player_width/2);
  line( player_width/2, -player_height/2, -player_width/2, player_width/2, -player_height/2, player_width/2);
  line(-player_width/2, player_height/2, -player_width/2, -player_width/2, player_height/2, player_width/2);
  line( player_width/2, player_height/2, -player_width/2, player_width/2, player_height/2, player_width/2);
  //box(player_width, player_height, player_width);

  //draw outline of player
  //vertical lines
  strokeWeight(2);
  hint(DISABLE_DEPTH_TEST);
  line(-player_width/2, -player_height/2, -player_width/2, -player_width/2, player_height/2, -player_width/2);
  line( player_width/2, -player_height/2, -player_width/2, player_width/2, player_height/2, -player_width/2);
  line(-player_width/2, -player_height/2, player_width/2, -player_width/2, player_height/2, player_width/2);
  line( player_width/2, -player_height/2, player_width/2, player_width/2, player_height/2, player_width/2);

  //x lines
  line(-player_width/2, -player_height/2, -player_width/2, player_width/2, -player_height/2, -player_width/2);
  line(-player_width/2, -player_height/2, player_width/2, player_width/2, -player_height/2, player_width/2);
  line(-player_width/2, player_height/2, -player_width/2, player_width/2, player_height/2, -player_width/2);
  line(-player_width/2, player_height/2, player_width/2, player_width/2, player_height/2, player_width/2);

  //z lines
  line(-player_width/2, -player_height/2, -player_width/2, -player_width/2, -player_height/2, player_width/2);
  line( player_width/2, -player_height/2, -player_width/2, player_width/2, -player_height/2, player_width/2);
  line(-player_width/2, player_height/2, -player_width/2, -player_width/2, player_height/2, player_width/2);
  line( player_width/2, player_height/2, -player_width/2, player_width/2, player_height/2, player_width/2);
  //box(player_width, player_height, player_width);
  hint(ENABLE_DEPTH_TEST);
  popMatrix();
}
void playSounds() {
  //-------------------------------------------------- MUSIC/sound effects
  if (!sound.isPlaying()) {
    if (fly) {
      if (Math.random() < 0.5) {
        sound = new SoundFile(this, ambientMusic[(int)(Math.random()*ambientMusic.length)]);
      } else {
        sound = new SoundFile(this, creativeMusic[(int)(Math.random()*creativeMusic.length)]);
      }
    } else {
      sound = new SoundFile(this, ambientMusic[(int)(Math.random()*ambientMusic.length)]);
    }
    sound.play();
    sound.amp(volume);
  }
  if (vel.mag() > 1 && soundTimer > 17/vel.mag()+Math.random()*2 && blockOn!=-1 && stepPath[blockOn].length > 0 && !fly) {
    int s = (int)(Math.random()*stepPath[blockOn].length);
    stepSounds[blockOn][s].play();
    stepSounds[blockOn][s].amp(0.5*volume);
    soundTimer = 0;
  } else {
    soundTimer ++;
  }
  if (vel.mag() > 0.5 && swimTimer > 30/vel.mag()+Math.random()*2 && inWater && !fly) {
    int s = (int)(Math.random()*swimSounds.length);
    swimSounds[s].play();
    swimSounds[s].amp(0.4*volume);
    swimTimer = 0;
  } else {
    swimTimer ++;
  }
}
void createNewChunks() {
  for (int x = (int)((cameraPos.x-renderDist)/chunkWidth - 1)*chunkWidth; x <= (int)((cameraPos.x+2*renderDist)/chunkWidth + 1)*chunkWidth; x+= chunkWidth) {
    for (int z = (int)((cameraPos.z-renderDist)/chunkWidth - 1)*chunkWidth; z <= (int)((cameraPos.z+2*renderDist)/chunkWidth + 1)*chunkWidth; z+= chunkWidth) {
      if (!chunkMap.containsKey(vectorHash(new PVector(x, 0, z)))) {
        Chunk newChunk = new Chunk(new PVector(x, 0, z), seed);
        chunks.add(newChunk);
        chunkMap.put(vectorHash(newChunk.pos), newChunk);
        newChunk.update();
        int[] dx = {0, 0, chunkWidth, -chunkWidth};
        int[] dz = {chunkWidth, -chunkWidth, 0, 0};
        for (int i = 0; i < 4; i++) {
          PVector target = PVector.sub(newChunk.pos, new PVector(dx[i], 0, dz[i]));
          if (chunkMap.containsKey(vectorHash(target))) {
            chunkMap.get(vectorHash(target)).update();
          }
        }
      }
    }
  }
}
void drawAllBlocks() {
  hint(DISABLE_DEPTH_TEST);
  ArrayList<Chunk> toDraw = new ArrayList();
  for (int i = 0; i < chunks.size(); ++i) {
    if (chunks.get(i).inRenderDist()) {
      toDraw.add(chunks.get(i));
    }
  }
  //toDraw.sort((a, b) -> Float.compare(distSquared(cameraPos, PVector.add(new PVector(chunkWidth/2, 0, chunkWidth/2), b.pos)), distSquared(cameraPos, PVector.add(new PVector(chunkWidth/2, 0, chunkWidth/2), a.pos))));
  ArrayList<Block> clear = new ArrayList();
  for (int i = 0; i < toDraw.size(); ++i) {
    clear.addAll(toDraw.get(i).draw());
  }
  clear.sort((a, b) -> Float.compare(distSquared(cameraPos, b.pos), distSquared(cameraPos, a.pos)));
  for (int i = 0; i < clear.size(); ++i) {
    clear.get(i).draw();
  }
}
Chunk getChunk(PVector v) {
  PVector c =  new PVector(floor(v.x/chunkWidth)*chunkWidth, 0, floor(v.z/chunkWidth)*chunkWidth);
  if (!chunkMap.containsKey(vectorHash(c))) return null;
  return chunkMap.get(vectorHash(c));
}
Block getBlock(PVector v) {
  v = round(v);
  Chunk chunk = getChunk(v);
  if (chunk == null) {
    return null;
  }
  if (!(chunk.blockMap.containsKey(vectorHash(v)))) {
    return null;
  }
  return chunk.blockMap.get(vectorHash(v));
}
PVector rotateVector(PVector v, PVector axis, float angle) {
  axis.normalize();
  float cosTheta = cos(angle);
  float sinTheta = sin(angle);

  PVector term1 = PVector.mult(v, cosTheta);
  PVector term2 = PVector.cross(axis, v, null).mult(sinTheta);
  PVector term3 = PVector.mult(axis, PVector.dot(axis, v) * (1 - cosTheta));

  return PVector.add(PVector.add(term1, term2), term3);
}
PVector rayFromMouse() {
  float clipHeight = 2*tan(fov/2);
  float clipWidth = clipHeight*width/height;

  PVector ray = new PVector(0, 0, 0);

  PVector right = PVector.cross(dir, new PVector(0, -1, 0), null).normalize();

  PVector up = PVector.cross(right, dir, null).normalize();

  ray.add(dir);
  ray.add(right.mult((mouseX-width/2)*1.0/width*clipWidth));
  ray.add(up.mult((mouseY-height/2)*1.0/height*clipHeight));
  return ray.normalize();
}

PVector[] mouseBlock() {
  PVector ray = rayFromMouse();
  ray.mult(0.1);
  PVector b = new PVector(playerPos.x, playerPos.y, playerPos.z);
  while (PVector.sub(b, playerPos).mag() < (fly?96:64)) {
    b.add(ray);
    if (getBlock(b) != null && (getBlock(b).blockType < 5 || getBlock(b).blockType > 7)) {
      PVector before = round(b);
      b.sub(ray);
      if(round(b).y > before.y && getBlock(b) != null){
        return new PVector[] {round(b), before};
      }
      return new PVector[] {before, round(b)};
    }
  }
  return null;
}
boolean collision(float[] pos, Block block) {
  return abs(pos[0]-block.pos.x) <= cubeSize/2 && abs(pos[1]-block.pos.y) <= cubeSize/2 && abs(pos[2]-block.pos.z) <= cubeSize/2;
}
boolean placeBlock() {
  PVector[] mouseB = mouseBlock();
  if (mouseB == null)
    return false;
  PVector block = mouseB[1];
  boolean canPlace = true;
  Chunk parentChunk = getChunk(block);
  if(getBlock(mouseB[0]) != null){
    if(getBlock(mouseB[0]).rightClicked()) return false;
  }
  if(parentChunk.blockMap.containsKey(vectorHash(block))) canPlace = false;
  Block hitBlock = new Block(block);
  for (int i = 0; i < hitbox.length; i++) {
    PVector box = PVector.add(hitbox[i], playerPos);
    if (hitBlock.collision(box) && blockSelected < 5)
      canPlace = false;
  }
  if (blockSelected >= 5 && blockSelected <= 7 && (block.y <= mouseB[0].y || getBlock(mouseB[0]).blockType >= 5)) canPlace = false;
  if (blockSelected > 7 && getBlock(mouseB[0]).blockType >= 5) canPlace = false;
  if ((blockSelected == 8 ||blockSelected==9)&& mouseB[0].y > block.y) canPlace = false;
  if (canPlace) {
    if (parentChunk.blockMap.containsKey(vectorHash(block))) {
      parentChunk.removeBlock(block);
    }
    int attached = -1;
    for(int i = 0; i < 6; i++)
      if(mouseB[0].equals(PVector.add(mouseB[1], hitBlock.sides[i]))) attached = i;
    int direction = -1;
    if(abs(dir.x) > abs(dir.z)){
      if(dir.x > 0){
        direction = 0;
      }
      else{
        direction = 1;
      }
    }
    else{
      if(dir.z > 0){
        direction = 2;
      }
      else{
        direction = 3;
      }
    }
    parentChunk.placeBlock(block, blockSelected, attached, direction);
    return true;
  }
  return false;
}
boolean breakBlock() {
  PVector[] mouseB = mouseBlock();
  if (mouseB == null)
    return false;
  PVector block = mouseB[0];
  if (block.y == worldBottom)
    return false;
  Chunk parentChunk = getChunk(block);
  parentChunk.breakBlock(block);
  return true;
  /*if(parentChunk.blockMap.containsKey(vectorHash(block))){
   Block breakBlock = parentChunk.blockMap.get(vectorHash(block));
   parentChunk.blocks.remove(breakBlock);
   return true;
   }*/
}
void playBreakSound(int block) {
  if (breakSounds[block].length == 0) return;
  int s = (int)(Math.random()*breakSounds[block].length);
  breakSounds[block][s].play();
  breakSounds[block][s].amp(0.5*volume);
}
void drawAxes() {
  stroke(255, 0, 0);
  line(0, 0, 0, 10000, 0, 0); // X-axis
  line(0, 0, 0, 0, 10000, 0); // Y-axis
  line(0, 0, 0, 0, 0, -10000); // Z-axis
  stroke(0);
}


long vectorHash(PVector p) {
  return (((long)(p.x / cubeSize + 524288) & 0xFFFFF)) |
    (((long)(p.y / cubeSize + 524288) & 0xFFFFF) << 20) |
    (((long)(p.z / cubeSize + 524288) & 0xFFFFF) << 40);
}
PVector round(PVector v) {
  return new PVector(
    round(v.x/cubeSize)*blockSize,
    round(v.y/cubeSize)*blockSize,
    round(v.z/cubeSize)*blockSize
    );
}
float distSquared(PVector v1, PVector v2) {
  return (v1.x-v2.x)*(v1.x-v2.x) + (v1.y-v2.y)*(v1.y-v2.y) + (v1.z-v2.z)*(v1.z-v2.z);
}
void keyPressed() {
  if (keyCode == CONTROL) {
    controlDown = true;
  }
  if (keyCode == UP) {
    volume *= 1.5;
    sound.amp(volume);
  } else if (keyCode == DOWN) {
    volume /= 1.5;
    if (volume < 0)
      volume = 0;
    sound.amp(volume);
  } else if (keyCode == LEFT) {
    renderDist -= 128;
    if (renderDist < 128)
      renderDist = 128;
  } else if (keyCode == RIGHT) {
    renderDist += 128;
  }
  if (key == '.') {
    defaultFov *= 0.8;
  }
  if (key == ',') {
    defaultFov /= 0.8;
    if (defaultFov > PI*0.8)
      defaultFov = PI*0.8;
  }
  if (keyCode == SHIFT) {
    shiftDown = true;
  }
  if (key < 256)
    keys[Character.toLowerCase(key)] = true;
  if (key == ' ') {
    if (System.currentTimeMillis()-spaceTime < 400) {
      fly = !fly;
    }
    spaceTime = System.currentTimeMillis();
  }
}
void keyReleased() {
  if (keyCode == CONTROL) {
    controlDown = false;
  }
  if (keyCode == SHIFT) {
    shiftDown = false;
  }
  if (key < 256) {
    keys[Character.toLowerCase(key)] = false;
  }
}
void mousePressed() {
  mouse.x = mouseX;
  mouse.y = mouseY;
  mouseTime = 0;
}
void mouseReleased() {
  mouse.x = -1;
  mouse.y = -1;
  if (mouseTime <= 10) {
    if (mouseButton == RIGHT) {
      //placeBlock();
    }
    if (mouseButton == LEFT) {
      //breakBlock();
    }
  }
}
import java.util.Arrays;
class Block {
  int blockType;
  PVector pos;
  float size = cubeSize;
  //pos x, neg x, pos z, neg z, pos y, neg y
  boolean[] sidecovered = new boolean[6];
  boolean[] redstoneup = new boolean[6];
  PVector[] sides = {new PVector(size, 0, 0), new PVector(-size, 0, 0), new PVector(0, 0, size), new PVector(0, 0, -size), new PVector(0, size, 0), new PVector(0, -size, 0)};
  float[][] sortedSides = new float[6][2];
  int power = 0;
  int strength = 0;
  int dir = -1;
  int attached = -1;
  int state = 0;
  int nextStrength = 0;
  int delay = -1;
  boolean flag = false;
  Chunk parentChunk;
  float squaredCamDist = -1;
  public Block(PVector v) {
    this(v, 0, null, -1, -1);
  }
  public Block(PVector v, int block, Chunk parentChunk, int attached, int dir) {
    pos = v;
    this.blockType = block;
    this.parentChunk = parentChunk;
    if(block == 8){
      strength = 15;
      nextStrength = 15;
    }
    this.dir = dir;
    this.attached = attached;
    update(true);
  }
  public Block(float x, float y, float z) {
    this(new PVector(x, y, z), 0, null, -1, -1);
  }
  public Block(float x, float y, float z, int block, Chunk parentChunk) {
    this(new PVector(x, y, z), block, parentChunk, -1, -1);
  }

  void draw() {
    if(!flag || blockType != 6)
      delay--;
    if(delay == 0){
      strength = nextStrength;
      updateNeighbors();
    }
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    if (transparent[blockType]) {
      //hint(DISABLE_DEPTH_TEST);
      for (int i = 0; i < 6; i++) {
        sortedSides[i][1] = i;
        sortedSides[i][0] = distSquared(PVector.add(pos, sides[i].copy().mult(0.5)), cameraPos);
      }
      Arrays.sort(sortedSides, (a, b) -> Float.compare(b[0], a[0]));

      for (int i = 0; i < 6; i++)
        drawSide((int)sortedSides[i][1]);
      //hint(ENABLE_DEPTH_TEST);
    } else {
      for (int i = 0; i < 6; i++)
        drawSide(i);
    }
    popMatrix();
  }
  boolean rightClicked(){
    if(blockType == 5 && flag){
      state = state^1;
      updateNeighbors();
      return true;
    }
    if(blockType == 6){
      state ++;
      if(state >= 4) state = 0;
      updateNeighbors();
      return true;
    }
    if(blockType == 7){
      flag = !flag;
      updateNeighbors();
      return true;
    }
    if(blockType == 9){
      state = state^1;
      strength = state*15;
      updateNeighbors();
      return true;
    }
    return false;
  }
  PImage recolor(PImage src, color tintColor) {
  // Create a new image the same size as src
  PImage result = createImage(src.width, src.height, ARGB);
  
  src.loadPixels();
  result.loadPixels();
  
  float tr = red(tintColor) / 255.0;
  float tg = green(tintColor) / 255.0;
  float tb = blue(tintColor) / 255.0;
  float ta = alpha(tintColor) / 255.0; // optional alpha tint
  
  for (int i = 0; i < src.pixels.length; i++) {
    color c = src.pixels[i];
    
    // Get original channels
    float r = red(c);
    float g = green(c);
    float b = blue(c);
    float a = alpha(c);
    
    // Multiply by tint color
    float nr = r * tr;
    float ng = g * tg;
    float nb = b * tb;
    float na = a * ta;
    
    // Assign to result
    result.pixels[i] = color(nr, ng, nb, na);
  }
  
  result.updatePixels();
  return result;
}
  void drawSide(int side) {
    if (blockType == 5) {
      pushMatrix();
      translate(0, -blockSize/2+0.01, 0);
      rotateX(PI/2);
      boolean dot = false;
      color strengthColor;
      if(strength > 0)
        strengthColor = color(100+strength*10, max(0, 22*strength-280), 0);
      else
        strengthColor = color(75, 0, 0);
      int n = 0;
        boolean opp = false;
        for(int i = 0; i < 4; i++){
          if(sidecovered[i]){
            n++;
            opp = sidecovered[i^1];
          }
        }
        if(n == 2 && opp){
          
        }
        else{
          dot = true;
          
        }
      if(side == 5 && dot){
        PImage subImg = atlas.get(85, 21, 6, 7);      // atlas region for dot
        PImage recolored = recolor(subImg, strengthColor);
        image(recolored, -3, -3, 6, 7);
      }
      if(sidecovered[side]){
        PImage subImg;
        PImage recolored;
        
        if (side == 1) {
          if (dot) {
            subImg = atlas.get(80, 32, 5, 16);      // atlas region for dot
            recolored = recolor(subImg, strengthColor);
            image(recolored, -size/2, -size/2, size/2 - 3, size);
          } else {
            subImg = atlas.get(80, 32, 8, 16);      // atlas region
            recolored = recolor(subImg, strengthColor);
            image(recolored, -size/2, -size/2, size/2, size);
          }
        }
        
        if (side == 0) {
          if (dot) {
            subImg = atlas.get(91, 32, 5, 16);
            recolored = recolor(subImg, strengthColor);
            image(recolored, 3, -size/2, size/2 - 3, size);
          } else {
            subImg = atlas.get(88, 32, 8, 16);
            recolored = recolor(subImg, strengthColor);
            image(recolored, 0, -size/2, size/2, size);
          }
        }
        
        if (side == 3) {
          if (dot) {
            subImg = atlas.get(80, 8, 16, 5);
            recolored = recolor(subImg, strengthColor);
            image(recolored, -size/2, -size/2, size, size/2 - 3);
          } else {
            subImg = atlas.get(80, 11, 16, 5);
            recolored = recolor(subImg, strengthColor);
            image(recolored, -size/2, -size/2, size, size/2);
          }
        }
        
        if (side == 2) {
          if (dot) {
            subImg = atlas.get(80, 4, 16, 4);
            recolored = recolor(subImg, strengthColor);
            image(recolored, -size/2, 4, size, size/2 - 4);
          } else {
            subImg = atlas.get(80, 0, 16, 8);
            recolored = recolor(subImg, strengthColor);
            image(recolored, -size/2, 0, size, size/2);
          }
        }
        if (redstoneup[side]) {
          popMatrix();
          pushMatrix();
          translate(sides[side].x/2 - Math.signum(sides[side].x)*0.01, 0, sides[side].z/2 - Math.signum(sides[side].z)*0.01);
          if (side < 4)
            rotateZ(PI);
          if (side == 0 || side == 1)
            rotateY(PI/2);
          subImg = atlas.get(80, 0, 16, 16);
          recolored = recolor(subImg, strengthColor);
          image(recolored, -blockSize/2, -blockSize/2, blockSize, blockSize);
        }
      }
      popMatrix();
      return;
    }
    if ((sidecovered[side] || !(cansee(side))) && !transparent[blockType])
      return;
    pushMatrix();
    int u = blockType*16;
    int v;
    if(blockType != 8 || attached != 5)
      translate(sides[side].x/2, sides[side].y/2, sides[side].z/2);
    else{
      if(side >= 4){
        popMatrix();
        return;
      }
      translate(sides[side].x/16, sides[side].y/16, sides[side].z/16);
    }
    if (side < 4)
      rotateZ(PI);
    if (side == 0 || side == 1)
      rotateY(PI/2);
    if (side == 4 || side == 5)
      rotateX(PI/2);
    if((blockType == 6 || blockType == 7 || blockType == 9) && !(blockType == 9 && attached != 5)){
      if(dir == 0){
        rotateZ(PI/2);
      }
      else if(dir == 1){
        rotateZ(-PI/2);
      }
      else if(dir == 2){
        rotateZ(PI);
      }
      else if(dir == 3){
        rotateZ(0);
      }
    }
    if (side < 4)
      v = 16;
    else if (side == 4)
      v = 0;
    else
      v = 32;
    if(blockType == 4){
      if(power > 0 || delay >= 0) v = 0;
      else v = 16;
    }
    if(blockType == 6 || blockType == 7){
      if(side == 4){
        popMatrix();
        return;
      }
      if(strength > 0){
        v = 32;
      }
      else{
        v = 0;
      }
    }
    if(blockType == 8){
      if(strength > 0) v = 16;
      else v = 0;
    }
    tint(235, 255);
    if(((blockType != 6 && blockType != 7) || side == 5) && blockType != 9 && !(blockType == 8 && attached != 5)){ 
      if (side < 4)
        image(atlas, -size/2, -size/2, size, size, u, v, u+16, v+16);
      if (side == 4)
        image(atlas, -size/2, -size/2, size, size, u, v, u+16, v+16);
      if (side == 5)
        image(atlas, -size/2, -size/2, size, size, u, v, u+16, v+16);
    }
    if(blockType == 8 && attached != 5){
      if(side != attached) {
        popMatrix();
        return;
      }
      image(atlas, -size/2, -size/2, size, size, u, v, u+16, v+16);
    }
    if(blockType == 9 && attached != 5){
      if(side == attached) {
        if(strength > 0) rotateZ(PI);
        image(atlas, -size/2, -size/2-3, size, size, u, v, u+16, v+16);
      }
      popMatrix();
      return;
    }
    if(blockType == 9){
      popMatrix();
      pushMatrix();
      //rotate
      if(side == 0){
        translate(4, -8, 0);
      }
      else if(side == 1){
        translate(-4, -8, 0);
      }
      else if(side == 2){
        translate(0, -8, 3);
      }
      else if(side == 3){
        translate(0, -8, -3);
      }
      else if(side == 4){
        translate(0, -5, 0);
      }
      rotateX(PI/2);
      if (side == 0 || side == 1){
        rotateX(PI/2);
        rotateY(PI/2);
      }
      if(side == 2 || side == 3){
        rotateX(PI/2);
        
      }
      //if(dir == 0)
      //  rotateZ(0);
      //if(dir == 1)
      //  rotateZ(PI);
      //if(dir == 2)
      //  rotateZ(PI/2);
      //if(dir == 3)
      //  rotateZ(-PI/2);
      
      
      
        
      if (side < 2)
        image(atlas, -3, -3, 6, 3, 9*16, 32, 9*16+6, 35);
      else if(side < 4)
        image(atlas, -4, -3, 8, 3, 9*16, 32, 9*16+8, 35);
      if (side == 4)
        image(atlas, -4, -3, 8, 6, 9*16, 32, 9*16+8, 38);
      popMatrix();
      pushMatrix();
      translate(0, -6, 0);
      rotateZ(PI);
      if(strength > 0)
      rotateZ(PI/4);
      else
      rotateZ(-PI/4);
      translate(0, 0, 1);
      image(atlas, -8, -14, 16, 14, 9*16, 16, 10*16, 30);
      translate(0, 0, -2);
      image(atlas, -8, -14, 16, 14, 9*16, 16, 10*16, 30);
      translate(1, 0, 1);
      rotateY(PI/2);
      image(atlas, -8, -14, 16, 14, 9*16, 16, 10*16, 30);
      translate(0, 0, -2);
      image(atlas, -8, -14, 16, 14, 9*16, 16, 10*16, 30);
      popMatrix();
      pushMatrix();
    }

    if(blockType == 6 && side < 4){
      PImage torch = atlas.get(128, (strength>0)?16:0, 16, 11);
      popMatrix();
      pushMatrix();
      translate(sides[side].x/16, 1, sides[side].z/16);
      translate(sides[dir].x*5/16, 0, sides[dir].z*5/16);
      rotateZ(PI);
      if (side == 0 || side == 1)
        rotateY(PI/2);
      image(torch, -size/2, -size/2+6, size, 11);
      popMatrix();
      pushMatrix();
      
      popMatrix();
      pushMatrix();
      translate(sides[side].x/16, 1, sides[side].z/16);
      translate(sides[dir].x*(-state*2+1)/16, 0, sides[dir].z*(-state*2+1)/16);
      rotateZ(PI);
      if (side == 0 || side == 1)
        rotateY(PI/2);
      image(torch, -size/2, -size/2+6, size, 11);
      popMatrix();
      pushMatrix();
    }
    if(blockType == 7 && side < 4){
      PImage torch = atlas.get(128, (strength>0)?16:0, 16, 11);
      PImage torchtip = atlas.get(128, (flag)?16:0, 16, 8);
      popMatrix();
      pushMatrix();
      translate(sides[side].x/16, 1, sides[side].z/16);
      translate(sides[dir].x*(-4)/16, 0, sides[dir].z*(-4)/16);
      if(sides[dir].x == 0){
        translate(-3, 0, 0);
      }
      else{
        translate(0, 0, -3);
      }
      rotateZ(PI);
      if (side == 0 || side == 1)
        rotateY(PI/2);
      image(torch, -size/2, -size/2+6, size, 11);
      popMatrix();
      pushMatrix();
      
      popMatrix();
      pushMatrix();
      translate(sides[side].x/16, 1, sides[side].z/16);
      translate(sides[dir].x*(-4)/16, 0, sides[dir].z*(-4)/16);
      if(sides[dir].x == 0){
        translate(3, 0, 0);
      }
      else{
        translate(0, 0, 3);
      }
      rotateZ(PI);
      if (side == 0 || side == 1)
        rotateY(PI/2);
      image(torch, -size/2, -size/2+6, size, 11);
      popMatrix();
      pushMatrix();
      
      
      popMatrix();
      pushMatrix();
      translate(sides[side].x/16, 1, sides[side].z/16);
      translate(sides[dir].x*(6)/16, 0, sides[dir].z*(6)/16);
      
      rotateZ(PI);
      if (side == 0 || side == 1)
        rotateY(PI/2);
      image(torchtip, -size/2, -size/2+9, size, 8);
      popMatrix();
      pushMatrix();
      
    }
    //if (this == destroyBlock && destroyStage < destroy.length) {
    //  if (side < 4)
    //    image(destroy[destroyStage], -size/2, -size/2, size, size);
    //  if (side == 4)
    //    image(destroy[destroyStage], -size/2, -size/2, size, size);
    //  if (side == 5)
    //    image(destroy[destroyStage], -size/2, -size/2, size, size);
    //}
    popMatrix();
  }
  boolean collision(PVector other) {
    return abs(other.x-pos.x) <= size/2 && abs(other.y-pos.y) <= size/2 && abs(other.z-pos.z) <= size/2;
  }
  int cover(Block other) {
    for (int i = 0; i < sides.length; i++) {
      PVector check = PVector.add(pos, sides[i]);
      if (check.x==other.pos.x && check.y == other.pos.y && check.z == other.pos.z)
        return i;
    }
    return -1;
  }
  void update(boolean forceUpdate){
    boolean neighborUpdate = forceUpdate;
    if(blockType == 5){
      int originalStrength = strength;
      strength = 0;
      for(int i = 0; i < 4; i++){
        sidecovered[i] = false;
        redstoneup[i] = false;
        PVector up = PVector.add(sides[4], PVector.add(sides[i], pos));
        PVector mid = PVector.add(sides[i], pos);
        PVector down = PVector.add(sides[5], PVector.add(sides[i], pos));
        PVector dirup = PVector.add(pos, sides[4]);
        Block midBlock = getBlock(mid);
        if (midBlock != null && midBlock.blockType == 5) {
          sidecovered[i] = true;
          strength = max(strength, midBlock.strength-1);
          continue;
        }
        if (midBlock != null && midBlock.blockType == 6 && (midBlock.dir == (i^1) || midBlock.dir == i)) {
          sidecovered[i] = true;
          if(midBlock.dir == (i^1))
            strength = max(strength, midBlock.strength);
          continue;
        }
        if (midBlock != null && midBlock.blockType == 7) {
          sidecovered[i] = true;
          if(midBlock.dir == (i^1))
            strength = max(strength, midBlock.strength);
          continue;
        }
        if (midBlock != null && midBlock.blockType > 7) {
          sidecovered[i] = true;
          strength = max(strength, midBlock.strength);
          continue;
        }
        if (midBlock != null && (midBlock.blockType < 3 || midBlock.blockType == 4) && midBlock.power == 3) {
          strength = max(strength, midBlock.strength);
          continue;
        }
        Block upBlock = getBlock(up);
        if (upBlock != null && upBlock.blockType == 5 && (getBlock(dirup) == null || transparent[getBlock(dirup).blockType])) {
          redstoneup[i] = true;
          sidecovered[i] = true;
          strength = max(strength, upBlock.strength-1);
          continue;
        }
        Block downBlock = getBlock(down);
        if (downBlock != null && downBlock.blockType == 5 && (midBlock == null || transparent[midBlock.blockType])) {
          sidecovered[i] = true;
          strength = max(strength, downBlock.strength-1);
          continue;
        }
      }
      if(originalStrength != strength) neighborUpdate = true;
      if (getBlock(PVector.add(pos, sides[5])) == null && parentChunk.blockMap.containsKey(vectorHash(pos))) {
        parentChunk.breakBlock(pos);
        return;
      }
      int n = 0;
      for (int i = 0; i < 6; i++) {
        if (sidecovered[i]) n++;
      }
      if (n == 0) {
        flag = true;
        if(state == 0){
          for (int i = 0; i < 4; i++) {
            sidecovered[i] = true;
          }
        }
      }
      else{
        flag = false;
      }
      if (n == 1) {
        for (int i = 0; i < 4; i++) {
          if (sidecovered[i]) {
            sidecovered[i^1] = true;
            break;
          }
        }
      }
    }
    if(blockType < 5 && blockType != 3){
      int prevPower = power;
      int prevStrength = strength;
      power = 0;
      strength = 0;
      for(int i = 0; i < 6; i++){
        Block b = getBlock(PVector.add(sides[i], pos));
        if(b == null) continue;
        if(b.blockType < 5 && b.blockType != 3 && b.power > 1){
          power = max(power, 1);
        }
        if(i < 4 && b.blockType == 5 && b.strength > 0 && b.sidecovered[i^1] && power <= 2){
          if(power == 2){
            strength = max(strength, b.strength);
          }
          else{
            power = 2;
            strength = b.strength;
          }
        }
        if(i == 4 && b.blockType == 5 && b.strength > 0 && power <= 2){
          if(power == 2){
            strength = max(strength, b.strength);
          }
          else{
            power = 2;
            strength = b.strength;
          }
        }
        if(b.blockType == 8 && b.strength > 0){
          if((i^1) == b.attached) continue;
          if(i == 5){
            power = 3;
            strength = 15;
          }
          else{
            if(power <= 1){
              power = 1;
              strength = 15;
            }
          }
        }
        if(b.blockType == 9 && b.strength > 0){
          if((i^1) == b.attached){
            power = 3;
            strength = 15;
          }
          else{
            if(power <= 2){
              power = 2;
              strength = 15;
            }
          }
        }
         
        if((b.blockType == 6 || b.blockType == 7) && b.strength > 0){
          if(b.dir == (i^1)){
            if(power == 3){
              strength = max(strength, b.strength);
            }
            else{
              power = 3;
              strength = b.strength;
            }
          }
        }
      }
      if(strength == 0 && blockType == 4 && prevStrength > 0){
        delay = 3;
      }
      if(strength != prevStrength || power != prevPower) neighborUpdate = true;
    }
    if(blockType == 8){
      Block attachedBlock = getBlock(PVector.add(pos, sides[attached]));
      if(attachedBlock == null){
        if(getBlock(pos) != null)
        parentChunk.breakBlock(pos);
        neighborUpdate = true;
      }
      else{
        if(attachedBlock.power > 1){
          if(strength != 0 && nextStrength != 0){
            delay = 1;
            nextStrength = 0;
          }
        }
        else{
          if(strength != 15 && nextStrength != 15){
            delay = 1;
            nextStrength = 15;
          }
        }
      }
        
    }
    if(blockType == 6){
      Block attachedBlock = getBlock(PVector.add(pos, sides[5]));
      if(attachedBlock == null){
        if(getBlock(pos) != null)
        parentChunk.breakBlock(pos);
        neighborUpdate = true;
      }
      else{
      Block[] side = new Block[] {getBlock(PVector.add(pos, sides[dir^2])), getBlock(PVector.add(pos, sides[dir^3]))};
      boolean lock = false;
      for(Block s:side){
        if(s == null) continue;
        if((s.blockType == 6 || s.blockType == 7) && s.strength > 0 && PVector.add(s.pos, s.sides[s.dir]).equals(pos)){
          lock = true;
        }
      }
      flag = lock;
      Block backBlock = getBlock(PVector.add(pos, sides[dir^1]));
      if(backBlock == null || backBlock.strength == 0){
        if(strength != 0 && nextStrength != 0){
          nextStrength = 0;
          delay = state+1;
        }
      }
      else if(backBlock.blockType <= 4 && backBlock.strength > 0 && backBlock.power > 1){
        if(strength != 15 && nextStrength != 15){
          nextStrength = 15;
          delay = state+1;
        }
      }
      else if((backBlock.blockType == 5||backBlock.blockType >= 8) && backBlock.strength > 0){
        if(strength != 15 && nextStrength != 15){
          nextStrength = 15;
          delay = state+1;
        }
      }
      else if((backBlock.blockType == 6||backBlock.blockType == 7) && backBlock.strength > 0 && backBlock.dir == dir){
        if(strength != 15 && nextStrength != 15){
          nextStrength = 15;
          delay = state+1;
        }
      }
      }
    }
    if(blockType == 7){
      Block attachedBlock = getBlock(PVector.add(pos, sides[5]));
      if(attachedBlock == null){
        if(getBlock(pos) != null)
        parentChunk.breakBlock(pos);
        neighborUpdate = true;
      }
      else{
      Block[] side = new Block[] {getBlock(PVector.add(pos, sides[dir^2])), getBlock(PVector.add(pos, sides[dir^3]))};
      int sideStrength = 0;
      for(Block s:side){
        if(s == null) continue;
        if(s.blockType == 5 && s.strength > 0){
          sideStrength = max(sideStrength, s.strength);
        }
        if((s.blockType == 6 || s.blockType == 7) && s.strength > 0 && PVector.add(s.pos, s.sides[s.dir]).equals(pos)){
          sideStrength = max(sideStrength, s.strength);
        }
      }
      Block backBlock = getBlock(PVector.add(pos, sides[dir^1]));
      int backStrength = 0;
      if(backBlock == null || backBlock.strength == 0){
          backStrength = 0;
        
      }
      else if(backBlock.blockType <= 4 && backBlock.strength > 0 && backBlock.power > 1){
          backStrength = backBlock.strength;
        
      }
      else if((backBlock.blockType == 5||backBlock.blockType >= 8) && backBlock.strength > 0){
          backStrength = backBlock.strength;
      }
      else if((backBlock.blockType == 6||backBlock.blockType == 7) && backBlock.strength > 0 && backBlock.dir == dir){
          backStrength = backBlock.strength;
        
      }
      int new_strength;
      if(flag){
        new_strength = max(0, backStrength-sideStrength);
      }
      else{
        if(backStrength >= sideStrength){
          new_strength = backStrength;
        }
        else{
          new_strength = 0;
        }
      }
      if(new_strength != strength && new_strength != nextStrength){
        nextStrength = new_strength;
        delay = 1;
      }
      }
    }
    if(blockType == 9){
       Block attachedBlock = getBlock(PVector.add(pos, sides[attached]));
      if(attachedBlock == null){
        if(getBlock(pos) != null)
        parentChunk.breakBlock(pos);
        neighborUpdate = true;
      }
    }
    if(neighborUpdate){
      for (int i = 0; i < 6; i++) {
        Block neighbor = getBlock(PVector.add(sides[i], pos));
        if (neighbor != null) {
          neighbor.update(false);
        }
      }
    }
  }
  void updateNeighbors() {
    update(true);
    updateCover();
    for (int i = 0; i < 6; i++) {
      {
        Block covering = getBlock(PVector.add(sides[i], pos));
        if (covering != null) {
          covering.updateCover();
        }
      }
      if (i < 4) {
        Block covering = getBlock(PVector.add(sides[4], PVector.add(sides[i], pos)));
        if (covering != null) {
          covering.updateCover();
        }
      }
      if (i < 4) {
        Block covering = getBlock(PVector.add(sides[5], PVector.add(sides[i], pos)));
        if (covering != null) {
          covering.updateCover();
        }
      }
    }
  }
  void updateCover() {
    //check all covering to do culling
    //if its dust, use this to check connectivity
    for (int i = 0; i < 6; i++) {
      if (blockType == 5) {
        
      } else {
        PVector toCheck = PVector.add(sides[i], pos);
        Block covering = getBlock(toCheck);
        if (covering == null) {
          sidecovered[i] = false;
          continue;
        }
        sidecovered[i] = (!transparent[covering.blockType]);
      }
    }

    //grass to dirt logic
    if (blockType <= 1) {
      Block covering = getBlock(PVector.add(sides[4], pos));
      if (covering != null)
        blockType = (!transparent[covering.blockType] || covering.blockType == 3)?0:1;
      else
        blockType = 1;
    }
  }
  boolean cansee(int side) {
    //more culling, dont render faces facing away
    PVector sidev = PVector.add(sides[side], pos);
    return distSquared(sidev, cameraPos) < distSquared(pos, cameraPos);
  }
  boolean equals(Block other) {
    return other.pos.x == pos.x && other.pos.y == pos.y && other.pos.z == pos.z;
  }
  void computeSquaredCamDist() {
    squaredCamDist = distSquared(pos, cameraPos);
  }
}
class Chunk {
  PVector pos;
  ArrayList<Block> blocks = new ArrayList();
  HashMap<Long, Block> blockMap = new HashMap();
  ArrayList<Block> toDraw = new ArrayList();
  PShape chunkShape;
  public Chunk(PVector pos, int seed) {
    this.pos = pos;
    for (int x = (int)pos.x; x < pos.x + chunkWidth; x += blockSize) {
      for (int z = (int)pos.z; z < pos.z + chunkWidth; z += blockSize) {
        addBlock(new PVector(x, 0, z), 2, -1, -1, false);
        addBlock(new PVector(x, blockSize, z), 0, -1, -1, false);
        addBlock(new PVector(x, blockSize*2, z), 0, -1, -1, false);
        addBlock(new PVector(x, blockSize*3, z), 1, -1, -1, false);
      }
    }
    for(int i = 0; i < operations.length; i++){
      if(operations[i].charAt(0) == 'r'){
        String[] parts = splitTokens(operations[i].substring(2), " ");

        float[] rm = new float[parts.length];
        
        for (int j = 0; j < parts.length; j++) {
          rm[j] = Float.parseFloat(parts[j]);
        }
        if(blockMap.containsKey(vectorHash(new PVector(rm[0], rm[1], rm[2])))){
          removeBlock(new PVector(rm[0], rm[1], rm[2]), false);
        }
      }
      else{
        String[] parts = splitTokens(operations[i], " ");

        float[] x = new float[parts.length];
        
        for (int j = 0; j < parts.length; j++) {
          x[j] = Float.parseFloat(parts[j]);
        }
        if(x[3] >= pos.x && x[3] < pos.x+chunkWidth && x[5] >= pos.z && x[5] < pos.z+chunkWidth){
          addBlock(new PVector(x[3], x[4], x[5]), (int)x[0], (int)x[1], (int)x[2], false);
        }
      }
    }
    update();
  }

  void update() {
    for (int i = 0; i < blocks.size(); ++i) {
      blocks.get(i).updateCover();
    }
  }
  void removeBlock(PVector v, boolean log) {
    if(log)
    output.println("r " + v.x + " " + v.y + " " + v.z); 
    Block toRemove = blockMap.get(vectorHash(v));
    blocks.remove(toRemove);
    blockMap.remove(vectorHash(v));
    toRemove.updateNeighbors();
  }
  void removeBlock(PVector v) {
    removeBlock(v, true);
  }
  void addBlock(PVector v, int blockType, int attached, int dir){
    addBlock(v, blockType, attached, dir, true);
  }
  void addBlock(PVector v, int blockType, int attached, int dir, boolean log) {
    Block b = new Block(v, blockType, this, attached, dir);
    if (blockMap.containsKey(vectorHash(v)))
      return;
    if(log)
      output.println(blockType + " " + attached + " " + dir + " " + v.x + " " + v.y + " " + v.z); 
    blocks.add(b);
    blockMap.put(vectorHash(v), b);
    b.updateNeighbors();
    //generated = 0;
  }
  void breakBlock(PVector v) {
    Block toRemove = blockMap.get(vectorHash(v));
    removeBlock(v);
    playBreakSound(toRemove.blockType);
    //generated = 0;
  }
  void placeBlock(PVector v, int blockType, int attached, int dir) {
    addBlock(v, blockType, attached, dir);
    playBreakSound(blockType);
  }
  ArrayList<Block> draw() {
    toDraw.clear();
    ArrayList<Block> clear = new ArrayList();
    for (int i = 0; i < blocks.size(); ++i) {
      blocks.get(i).computeSquaredCamDist();
      if (blocks.get(i).squaredCamDist < renderDist*renderDist) {
        //if (!transparent[blocks.get(i).blockType]) {
          //blocks.get(i).draw();
        //} else
          clear.add(blocks.get(i));
      }
    }
    return clear;
  }
  boolean inRenderDist() {
    return distSquared(pos, cameraPos) < (renderDist+chunkWidth*2)*(renderDist+chunkWidth*2);
  }
  long vectorHash(PVector p) {
    return (((long)(p.x / cubeSize + 524288) & 0xFFFFF)) |
      (((long)(p.y / cubeSize + 524288) & 0xFFFFF) << 20) |
      (((long)(p.z / cubeSize + 524288) & 0xFFFFF) << 40);
  }
}
