int total = 32;//images
int totalFrames = total*2-2;
int space = totalFrames/6;
PImage[] images = new PImage[total];
int[] frames = new int[totalFrames];
void setup() {
 size(565, 800);
 background(0);
 
 for(int i=0; i<total; i++){
   images[i] = loadImage(i+".png");
 }
 int counter = 0;
 for(int i=0; i<total; i++){
   frames[counter] = i;
   counter++;
 }
 for(int i=total-2; i>0; i--){
   frames[counter] = i;
   counter++;
 }
 frameRate(3);
}

void draw(){
  rotate(PI/2);
  image(images[frames[(frameCount+0*space) % frames.length]], 400, -565, 400, 565);
  
  rotate(PI/2);
  image(images[frames[(frameCount+1*space) % frames.length]], -282, -400, 282, 400);
  
  rotate(PI/2);
  image(images[frames[(frameCount+2*space) % frames.length]], -200, 282, 200, 282);
  
  rotate(PI/2);
  image(images[frames[(frameCount+3*space) % frames.length]], 423, 200, 141, 200);
  
  rotate(PI/2);
  image(images[frames[(frameCount+4*space) % frames.length]], 300, -423, 100, 141);
  
  rotate(PI/2);
  image(images[frames[(frameCount+5*space) % frames.length]], -352, -300, 70, 100);
  
  saveFrame("frame"+frameCount+".tiff");
  if(frameCount==frames.length) exit();
}
