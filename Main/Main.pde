/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/64754*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */
// Pierre MARZIN
// Trying to learn Processing... First project, much inspired by "Mycelium" by Scloopy?
// http://marzinp.free.fr/applets

//GUI and Drag 'n drop: great libraries ! Thanks to Andreas Schlegel (http://www.sojamo.de/libraries/index.html)
//GUI variables
//SDrop drop;
public String mUrl;
import processing.pdf.*;


/* @pjs preload="base.png"; */
int counter = 0;
PImage source;      // Source image
//for each "worm", variables: position

//aimed direction
PVector vise=new PVector();
int locPixel;
ArrayList <Seeker> seekersArray;
float seekX,seekY;
//worm's length
int maxLength;
int maxLayers;
//like pixels[], to keep track of how many times a point is reached by a worm
int [] buffer;
int [] limiteDown;
//number of worms at the beginning
int nbePoints;
public float inertia;
//width and length of the drawing area
int larg;
int haut;
int largI;
int hautI;
//brightness of the destination pixel
float briMax;
//minimum brightness threshold
public int seuilBrillanceMini;
//maximum brightness threshold
public int seuilBrillanceMaxi;
//location of the tested point in pixels[]
int locTest;
int locTaX;
    int locTaY;
int brightnessTemp;
//around a point (worms position), how many pixels will we look at...
int amplitudeTest;
//constrain the acceleration vector into a devMax radius circle
float devMax;
//constrain the speed vector into a vMax radius circle
float vMax;
//not used:random factor
int hasard;
//stroke's weight (slider) or radius of ellipse used for drawing
public float myweight;
//draw or not (button onOffButton)
public boolean dessine=true;
//different drawing options
public int modeCouleur;
//fill color
int macouleur;
boolean limite;

//setup only sets up what won't change:GUI and window params
//I use initialiser() to set up what has to be initialised
//when you hit "ResetButton" and dessin() to set the drawing parameters
void setup() {
  larg=largI=842;
  haut=hautI=1192;

  size(842,1192);
  beginRecord(PDF, "everything.pdf");
  //sound useSound=false;
  limite=false;
  //sound minim = new Minim(this);
  //drop = new SDrop(this);
 // f = loadFont("ArialUnicodeMS-12.vlw");
  source = loadImage("base.png");
  if(hautI*source.width>largI*source.height){
    larg=largI;
    haut=larg*source.height/source.width;
  }else{
    haut=hautI;
    larg=haut*source.width/source.height;
  }
source.resize(larg,haut);
source.loadPixels();
  fill(0);
  initialiser();
}

//launched after setup and any time you hit the ResetButton button
public void initialiser() { 
  dessine=true;
  nbePoints=6;
  fill( 0 );
  stroke( 0 );
  rect( 0, 0, larg,haut );
  buffer=new int[haut*larg];
  smooth();
  inertia=6;
  maxLayers=10;
  myweight=.2;
  seuilBrillanceMaxi=200;
  seuilBrillanceMini=0;
  amplitudeTest=1;
  maxLength=300;
  limite=true;
  hasard=0;
  devMax=8;
  vMax=50;
  modeCouleur=1;
  strokeJoin(ROUND);
  seekersArray=new ArrayList <Seeker>();
 
  for(int i=0;i<nbePoints;i++) {
    
    Seeker mSeeker=new Seeker(new PVector(random(larg),random(haut)),new PVector(random(-3,3),random(-3,3)),inertia);
    
    while((brightness(mSeeker.getImgPixel())>seuilBrillanceMaxi)||(brightness(mSeeker.getImgPixel())<seuilBrillanceMini))
    {
      mSeeker.setP(int(random(larg)),int(random(haut)));
    }
    seekersArray.add(mSeeker);
  }
}

void draw() {

 if (dessine){
      for (int i = 0; i < nbePoints; i++) {
        Seeker mSeeker = seekersArray.get(i);
        dessin(mSeeker);
        if (mSeeker.isDeplace()) {
          mSeeker.setDeplace(false);
        }
   }
 }
 
 if(frameCount%40==0){
   saveFrame(counter+".png");
   counter++;
 }
}

void keyPressed(){
  if (key == 's' || key == 'S') {
    saveFrame();
  }
  if (key == 'q') {
    endRecord();
    exit();
    println("fechou?");
  }
}
  void dessin(Seeker mySeeker) {

    // for each "seeker" (worm's head)
    // //on va tester les pixels autour du mobile p[t] en direction de la
    // vitesse du mobile
    // //calcul du barycentre des points testes ponderes de la brillance
    // (vise.x, vise.y)
    // //for each seeker, we gonna test pixels around the seeker's position
    // and calculate their barycenter, loaded by pixels values (0/255
    // dark/light);
    // barycenter's coordinates
    //myweight=window.inertia;
    vise.x = 0;
    vise.y = 0;
    // avoid looking for mySeeker.p.x for every pixels
    seekX = mySeeker.getP().x;
    seekY = mySeeker.getP().y;
    int pixelsPosition = floor(seekX) + floor(seekY) * larg;
    int locTestX = floor(seekX);
    int locTestY = floor(seekY);
    
    // barycenter calculation
    for (int i = -amplitudeTest; i < amplitudeTest + 1; i++) {// /rdessin
      for (int j = -amplitudeTest; j < amplitudeTest + 1; j++) {
        locTaX = locTestX + i;
        locTaY = locTestY + j;
        // does the point belongs to the source image?
        if ((locTaX > 0) && (locTaY > 0) && (locTaX < larg - 1) && (locTaY < haut - 1)) {
          brightnessTemp = int(brightness(source.pixels[locTaX + larg * locTaY]));
          vise.sub(new PVector(i * brightnessTemp, j * brightnessTemp));
        }
      }
    }
    // coeur du comportement de seeker:
    // core of the behaviour of the seeker (http://www.shiffman.net/ see
    // wanderer's code)

    vise.normalize();
    vise.mult(100f/mySeeker.inertia);
    mySeeker.getV().add(new PVector(vise.x,vise.y));
    PVector deviation = mySeeker.getV().get();
    deviation.normalize();
    deviation.mult(devMax);
    mySeeker.getV().normalize();
    mySeeker.getV().mult(vMax);
    mySeeker.getP().add(deviation);
    // ******************different cases that lead to move the seeker to
    // another random place**************
    // outside window
    // on compte les segments de chaque ver
    // worm's length is increased
    mySeeker.setLongueur(mySeeker.getLongueur() + 1);
    float positionBrightness=brightness(mySeeker.getImgPixel());
    //println(positionBrightness+" "+mySeeker.getP().x+" "+mySeeker.getP().y);
    //dessine=false;
    // si c'est trop long on demenage
    // seeker's moved if worm's too long
    if (mySeeker.getLongueur() > maxLength) {
      deplacePoint(mySeeker);
    }
    if ((mySeeker.getP().x < 1) || (mySeeker.getP().y < 1) || (mySeeker.getP().x > larg - 1) || (mySeeker.getP().y > haut - 1))// ||
    {
      mySeeker.setDeplace(true);
      deplacePoint(mySeeker);
      return;
    }
    // buffer est une copie vide de l'image. on l'augmente pour chaque point
    // parcouru
    // buffer is an empty copy of the source image. It's increased every
    // time a point is reached.
    buffer[pixelsPosition]++;
    // si on est passe plus de n fois on demenage le point
    // If a point is reached n times, seeker is moved
    if (buffer[pixelsPosition] > maxLayers) {
      deplacePoint(mySeeker);
    }

    // inside window, limite on and inside value range
    if ((limite) && (positionBrightness <= seuilBrillanceMaxi) && (positionBrightness >= seuilBrillanceMini)) {
      if (mySeeker.getLimiteDown() != 0) {
        mySeeker.setLimiteDown(mySeeker.getLimiteDown() - 2);
      }
    }
    // limite on and outside value range
    if ((limite) && ((positionBrightness > seuilBrillanceMaxi) || (positionBrightness < seuilBrillanceMini))) {
      if (mySeeker.getLimiteDown() == 0) {
        mySeeker.setLimiteDown(2);
      }
      mySeeker.setLimiteDown(mySeeker.getLimiteDown() + 4);// print(mySeeker.limiteDown+" ");
      if (mySeeker.getLimiteDown() >= 152 / myweight) {
        mySeeker.setLimiteDown(0);
        deplacePoint(mySeeker);
      }
    }
    // null deviation
    if ((deviation.x == 0) && (deviation.y == 0)) {
      mySeeker.setLimiteDown(0);
      deplacePoint(mySeeker);
    } 
      else briMax = brightness(source.pixels[pixelsPosition]);
    
    // go draw the seeker's shape
    mySeeker.setDia((float) (myweight * (1 - cos((mySeeker.getLongueur()) * PI * 2 / (float) maxLength))));
    mySeeker.setAlpha((max(0, (round(127 * mySeeker.getDia() / myweight) - (int) briMax / 2))));
    float r = red(mySeeker.getImgPixel());
    float g = green(mySeeker.getImgPixel());
    float b = blue(mySeeker.getImgPixel());
    
    stroke(0);
    strokeWeight(mySeeker.getDia()*3+5);
    line(seekX,seekY,mySeeker.getP().x,mySeeker.getP().y);
    
    stroke(r, g, b, brightness(mySeeker.getImgPixel())+100);
    strokeWeight(mySeeker.getDia()*3+3);
    line(seekX,seekY,mySeeker.getP().x,mySeeker.getP().y);
    //println("Size "+mySeeker.getDia());
    // on cree un nouveau vers de temps en temps (on pourrait tester selon
    // la brilance de la zone...)
    // from times to times a new worm is created
    if (random(1) > 1 - (255 - briMax) / (500 * seekersArray.size())) {
      seekersArray.add(new Seeker(new PVector(seekX, seekY), new PVector(mySeeker.getV().x * random(-3,3), mySeeker.getV().x
          * random(-3,3)), inertia));
      nbePoints++;
      // Log.d("DrawingView","Size "+seekersArray.size());
    }
  }

  // *****************move the seeker function***************************
  void deplacePoint(Seeker seeker) {
    seeker.setLongueur(0);
    seeker.setP(random(1, larg - 1), random(1, haut - 1));
    while ((brightness(seeker.getImgPixel()) > seuilBrillanceMaxi)
        || (brightness(seeker.getImgPixel()) < seuilBrillanceMini)) {
      seeker.setP(random(1, larg - 1), random(1, haut - 1));
    }
    seekX = seeker.getP().x;
    seekY = seeker.getP().y;
  }
public void setDevMax(float devMax) {
    this.devMax = devMax;
  }
public class Seeker {

  // position
  private PVector p = new PVector();
  // speed
  private PVector v = new PVector();
  private int imgPixel;
  private float inertia;
  // worm's length
  private float longueur;
  // worm's limite
  private int limiteDown;
  private int couleur;
  private int red = int(random(0, 100));
  // stroke weight
  private float dia;
  private boolean deplace;
  private int alpha;
  private float greenfade = random(1);
  private float bluefade = random(1);
  private float redfade = random(1);
  private float vegRatio = random(.75, 1);

  // Constructor
  public Seeker(PVector P, PVector V, float Inertia) {
    p = P;
    v = V;
    limiteDown = 0;
    longueur = 0;
    setInertia(random(-2, 2) + Inertia);
    setDeplace(false);
  }

  public int updateCouleur() {

    float green = green(couleur);
    float blue = blue(couleur);
//    if (view.getStyle() == DrawingView.STYLE_VEGETAL) {
//      if ((green > 150) || (green < 1))
//        greenfade = -greenfade;
//      green += greenfade;
//      if ((blue > 50) || (blue < 1))
//        bluefade = -bluefade;
//      blue += bluefade;
//      if ((red > 50) || (red < 1))
//        redfade = -redfade;
//      red += redfade;
//      couleur = Color.argb(alpha, red, green, blue);
//    } else if (view.getStyle() == DrawingView.STYLE_NORMAL) {
      if ((green > 100) || (green < 1))
        greenfade = -greenfade;
      green += greenfade;
      if ((blue > 100) || (blue < 1))
        bluefade = -bluefade;
      blue += bluefade;
      couleur =color(alpha, red, green, blue);
//    }
//    else if (view.getStyle() == DrawingView.STYLE_NEGATIF) {
//      couleur = Color.WHITE;
//    }
    return couleur;
  }

  public float getLongueur() {
    return longueur;
  }

  public void setLongueur(float longueur) {
    this.longueur = longueur;
  }

  public PVector getP() {
    return p;
  }

  public void setP(PVector p) {
    this.p = p;
  }

  public void setP(float a, float b) {
    this.p.x = a;
    this.p.y = b;
  }

  public PVector getV() {
    return v;
  }

  public void setV(PVector v) {
    this.v = v;
  }

  public void setV(float a, float b) {
    this.v.x = a;
    this.v.y = b;
  }

  public int getLimiteDown() {
    return limiteDown;
  }

  public void setLimiteDown(int limiteDown) {
    this.limiteDown = limiteDown;
  }

  public boolean isDeplace() {
    return deplace;
  }

  public void setDeplace(boolean deplace) {
    this.deplace = deplace;
  }

  public float getDia() {
    return dia;
  }

  public void setDia(float dia) {
    this.dia = dia;
  }

  public int getAlpha() {
    return alpha;
  }

  public void setAlpha(int alpha) {
    this.alpha = alpha;
  }

  public float getInertia() {
    return inertia;
  }
public void setInertia(float inertia) {
    this.inertia = inertia;
  }
  

  public int getCouleur() {
    return couleur;
  }

  public void setCouleur(int couleur) {
    this.couleur = couleur;
  }

  public float getVegRatio() {
    return vegRatio;
  }

  public void setVegRatio(float vegRatio) {
    this.vegRatio = vegRatio;
  }
  public int getImgPixel(){
    if(getP().x>0 && getP().x<larg &&getP().y>0 && getP().y<haut)
    return source.pixels[floor(getP().x)+floor(getP().y)*larg];
    else{
      //println("Out of range");
      return 0;
    }
}
}
