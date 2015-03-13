class Building {

  float timeFraction;

  // use the PVector to store the x,y
  PVector lonLat = new PVector();
  //  PVector pos = new PVector(width/2-72, height-height/20-40); // because we need the position on the screen
  PVector pos = new PVector();
  PVector tpos = new PVector(); // because it's an animation, we need time.

  SimplePointMarker buildingMarker; // mark the geo info
  SimplePointMarker selectMarker; // show the general info when picking

  String address;
  String owner;
  String phasingOut6Oil;
  String boilerModel;
  float boilerNum;
  float boilerCap;
  int boilerInsDate;
  int boilerEndDate;
  String boilerFuel;

  float boilerHighCosumGallon;
  float boilerLowCosumGallon;
  float boilerHighCosumMMBTUs;
  float boilerLowCosumMMBTUs;
  float avgCosumGallon;

  String boilerComplyLaw; 
  String boilerComplyLawDeadline;

  String buildingType;
  float buildingArea;
  float buildingFloors;
  float buildingResidentialUnits;
  int buildingTotalUnits;
  int buildingYearCons;
  float avgCosumGallonPerUnit;

  int frameCounter;

  void init() {
    //    println("init the Building");
  } 

  void update() {
    frameCounter ++;
    //    pos.lerp(tpos, 0.1);  //for creating motion along a straight path and for drawing dotted lines
  }
  void render() {
    if (buildingMarker != null) {
      noStroke();
      fill(caltulateColor(avgCosumGallonPerUnit), 75, 75, 200);
      pushMatrix();
      // get the position of marker

      ScreenPosition thisPos = buildingMarker.getScreenPosition(map);
      translate(thisPos.x, thisPos.y); // draw a elliper on the pos.x/y/z
      ellipse(0, 0, 4, 4);
      popMatrix();
      emit(thisPos.x, thisPos.y);
      selected(thisPos.x, thisPos.y);
    }
  }
  void emit(float thisX, float thisY) {
    fill(caltulateColor(avgCosumGallonPerUnit), 75, 75, frameCounter%100);
    stroke(caltulateColor(avgCosumGallonPerUnit), 75, 75, 60);
    pushMatrix();
    translate(thisX, thisY); // draw a elliper on the pos.x/y/z
    ellipse(0, 0, 15-frameCounter%60/3, 15-frameCounter%60/3);
    popMatrix();
  }

  int caltulateColor(float num) {
    // hue: red - green : 0 - 120
    return int(map(num, 8000, 10, 0, 140));
  }

  void selected(float thisX, float thisY) {
    if (abs(mouseX - thisX) < 3 && abs(mouseY - thisY) < 3) {
      println(avgCosumGallonPerUnit);
      int sendData = int(map(avgCosumGallonPerUnit, 0, 8000, 100, 10));
      port.write(sendData);
      pushMatrix();
      translate(thisX, thisY);
      fill(0, 0, 0, 150);
      rect(0, 0, 350, 175);
      textAlign(LEFT);
      noStroke();
      fill(0, 0, 100, 255);
      textFont(font, 12);
      text("Estimated Cosumption (Gallons)", 15, 15);
      textFont(font, 18);
      text(avgCosumGallonPerUnit, 10, 35);
      textFont(font, 12);
      text("Address:", 15, 60);
      text(address, 15, 75);
      text("Boiler Installation Date:", 15, 90);
      text(boilerInsDate, 190, 90);
      text("Comply with Greener Greater Buildings Laws:", 15, 105);
      text(boilerComplyLaw, 320, 105);
      text("Building Type:", 15, 120);
      text(buildingType, 100, 120);
      text("Number of total units:", 15, 135);
      text(buildingTotalUnits, 190, 135);
      text("Year constructed:", 15, 150);
      text(buildingYearCons, 140, 150);
      popMatrix();
    }
  }
} // end of class

