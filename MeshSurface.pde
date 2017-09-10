import org.processing.wiki.triangulate.*;

PVector mousePos;

Surface surface;

void setup() {

  size(800, 600, P3D);
  pixelDensity(2);
  
  surface = new Surface(500, 500);
  surface.load("points_reduced.txt", "grayscale.jpg", 500);
  
}


void draw() {

  background(255);
  
  surface.plot(width/2, height/2);
  
}

void keyPressed() {
  switch(key) {
    case 't':
      surface.textureView();
      break;
    case 's':
      surface.strokeView();
      break;
  }
}

void mousePressed() {
  mousePos = new PVector(mouseX, mouseY);
}

void mouseDragged() {
  surface.rotate( map(mousePos.x - mouseX, 0, width, 0, 2*PI) );
  mousePos.set(mouseX, mouseY);
}




public class Surface {

  private int width,
              height;
  private PVector min,
                  max;
  private PImage texture;
  private ArrayList<Triangle> faces;
  private float rotation;
  
  private boolean showTexture;
  private boolean showStroke;
  
  Surface(int width, int height) {
    this.width = width;
    this.height = height;
  }
  
  public void textureView() { showTexture = !showTexture; }
  public void strokeView() { showStroke = !showStroke; }
  
  public void rotate(float rotation) { this.rotation += rotation; }
  
  public void load(String path, String img, int count) {
    
    //PrintWriter output = createWriter("points_reduced.txt");
    //output.println("x,y,z");
    
    println("Creating SURFACE...");
    
    ArrayList<PVector> pointCloud = new ArrayList<PVector>();
    min = new PVector(Float.MAX_VALUE, Float.MAX_VALUE, Float.MAX_VALUE);
    max = new PVector(Float.MIN_VALUE, Float.MIN_VALUE, Float.MIN_VALUE);
    
    String[] points = loadStrings(path);
    int sampling = points.length / count;
    
    print("Loading points (" + points.length + " > " + count + ")... ");
    for(int i = 1; i < points.length; i = i + sampling) {
      
      String[] p = split(points[i], ",");
      PVector point = new PVector(float(p[0]), float(p[1]), float(p[2]));
      pointCloud.add( point );
      
      //output.println(float(p[0]) + "," + float(p[1]) + "," + float(p[2]));
      
      // Update surface limits ---->
      if(point.x < min.x) min.x = point.x;
      if(point.x > max.x) max.x = point.x;
      if(point.y < min.y) min.y = point.y;
      if(point.y > max.y) max.y = point.y;
      if(point.z < min.z) min.z = point.z;
      if(point.z > max.z) max.z = point.z;
      
    }
    println("DONE");
    
    //output.flush();
    //output.close();
    
    println(min.x + "," + min.y + "," + min.z);
    println( (max.x - min.x) + "," + (max.y - min.y) + "," + (max.z - min.z) );
    
    
    print("Mapping points... ");
    for(PVector point : pointCloud) {
      point.x = map(point.x, min.x, max.x, 0, width );
      point.y = map(point.y, min.y, max.y, 0, height );
      point.z = map(point.z, min.z, max.z, 0, 100 );
    }
    println("DONE");
    
    
    print("Creating faces... ");
    faces = Triangulate.triangulate(pointCloud);
    println("DONE");
    
    println("SURFACE created");
    
    texture = loadImage(img);
    texture.resize(width, height);
    showTexture = true;
    
  }
  
  
  public void plot(int xCenter, int yCenter) {
    
    pushMatrix();
    
    if(!showTexture) lights();
    
    translate(xCenter, yCenter);
    rotateX(PI/3);
    rotateZ(rotation);
    translate(-width/2, -height/2);
    
    beginShape(TRIANGLES);
    
    //stroke(#000000); strokeWeight(1);
    noStroke();
    if(showTexture) { 
      noFill();
      texture(texture);
    } else fill(#F0F0F0);
    
    if(showStroke) stroke(#000000);
    
    for(Triangle face : faces) {
      vertex(face.p1.x, face.p1.y, face.p1.z, face.p1.x, face.p1.y);
      vertex(face.p2.x, face.p2.y, face.p2.z, face.p2.x, face.p2.y);
      vertex(face.p3.x, face.p3.y, face.p3.z, face.p3.x, face.p3.y);
    }  
    
    endShape();
    
    popMatrix();
    
  }
  
  
}