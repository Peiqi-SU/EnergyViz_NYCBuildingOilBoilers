/*
* data sample:
 * <header>
 0                           1                 2                                               3                4      5            6                        7                                                                                        8            9                           10                          11                          12                                                                        13                          14                  15            16          17                                                    18                                                  19                                                    20                                                   21                                                  22                                                           23             24                   25                             26                                        27               28                           29                    30               31                  32
 "Borough, Block and Lot #",Facility Address,Natural Gas Utility (Con Edison or National Grid,Building Manager,Owner,Owner Address,DEP Boiler Application #,Deadline for phasing out #6 oil (i.e. data of next DEP permit renewal after July 1 2012),Boiler Model,Number of identical boilers,Boiler capacity (Gross BTU),Boiler Installation Date,Estimated retirement date of boiler (assuming 35 year average useful life),Is boiler dual fuel capable?,Age range of boiler,Burner Model,Primary Fuel,Total Estimated Cosumption - High Estimate (Gallons) ,Total Estimated Cosumption - Low Estimate (Gallons) ,Total Estimated Cosumption - High Estimate (MMBTUs) ,Total Estimated Cosumption - Low Estimate  (MMBTUs) ,Needs to comply with Greener Greater Buildings Laws?,Deadline for complying with Audit and Retrocommissioning Law,Building Type,City Council District,Total area of buildings on lot,Number of buildings on property (tax lot),Number of floors,Number of residential units,Number of total units,Year constructed,Condominium housing?,Cooperative housing? 
 * <row>             
 2057800940,"3900 GREYSTONE AVENUEBronx, NY 10463(40.88950389842045, -73.9044515066065)",Con Edison,TROY PITTS SPRINT,"WIENER, EDITH","855 AVEMANHATTAN, NY 10001(40.75025902143676, -73.99688630375988)",CA014493L,7/6/05,FEDERAL FST-150,2,6.27,1993,2028, ,16 to 20 years old,I.C.I. DEG-63 P,#6,550000,385000,82500,57750,Yes,2020,Elevator Apartments,11,134703,2,6,127,127,1928, , 
 * 1 header + 8047 lines + 1 last line
 
 * use unfolding t generate the map as background
 
 * Year construct the building: 1848, some are 0. 
 building 1848 - 2013 = 165 years;
 display 1845 - 2015 = 170years
 
 */
import processing.serial.*;
Serial port;

import java.util.*; // for the Data obj

// For Unfolding map
//import processing.opengl.*;
//import codeanticode.glgraphics.*;
//import de.fhpotsdam.unfolding.*;
//import de.fhpotsdam.unfolding.geo.*;
//import de.fhpotsdam.unfolding.utils.*;
//import de.fhpotsdam.unfolding.marker.SimplePointMarker;
//import de.fhpotsdam.unfolding.providers.*;
//import de.fhpotsdam.unfolding.mapdisplay.MapDisplayFactory;
import de.fhpotsdam.unfolding.mapdisplay.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.tiles.*;
import de.fhpotsdam.unfolding.interactions.*;
import de.fhpotsdam.unfolding.ui.*;
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.core.*;
import de.fhpotsdam.unfolding.mapdisplay.shaders.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.texture.*;
import de.fhpotsdam.unfolding.events.*;
import de.fhpotsdam.utils.*;
import de.fhpotsdam.unfolding.providers.*;


// BufferedReader will read one line each time
BufferedReader myReader;

// Create a reference to a “Map” object, i.e.
UnfoldingMap map;

// parameters for parsing data
int biggestConsumer = 0;
int smallestConsumer = 10000;
int biggestConsumerID = 0;
int smallestConsumerID = 0;

// array to hold the dot
ArrayList<Building> buildings = new ArrayList();
PFont font;
PFont fontSmall;
PImage imgNYC, imgEg;
float timefly = 0;
int border = 25;
int yearsDur = 165;

void setup() {
  //  size(800, 700, GLConstants.GLGRAPHICS); 
  size(800, 700, P2D); 
  colorMode(HSB, 360, 100, 100, 255);
  frameRate(30);
  font = loadFont("Georgia-BoldItalic-48.vlw");
  fontSmall = loadFont("Georgia-14.vlw");

  setupUnfoldingMap();

  //  imgNYC = loadImage("Time_Space_02.png");
  imgEg = loadImage("eg.png");

  // manage .csv : 1) load to table; 2) load string funtioin
  // will be load into memory --> bad for big data set
  // ! so use BufferedReader
  myReader = createReader("Oil_Boilers_Data.csv");
  parseData();
  findConsumer();
  
  //port = new Serial(this, Serial.list()[0], 57600);
  port = new Serial(this, "/dev/tty.Smalldownloader-SPPDev", 57600);
  //port = new Serial(this, "/dev/tty.usbmodem1411", 57600);
  
}

void draw() {
  //    image(imgNYC, 0, 0);
  map.draw();
  for (Building b : buildings) {
    if (b.timeFraction < timefly) {
      b.update();
      b.render();
    }
  }
  render();
}

void setupUnfoldingMap() {
  // customize map here. 65678:white; 78603: black; 998: old; 67367: blue; 33332: dark-blue; 73032:litht-blue; 88071: blue-grey
  // edit style here: http://maps.cloudmade.com/editor
  //  map = new UnfoldingMap(this, new OpenStreetMap.CloudmadeProvider(MapDisplayFactory.OSM_API_KEY, 88071)); 
  map = new UnfoldingMap(this); 
  MapUtils.createDefaultEventDispatcher(this, map);
  Location NYCLocation = new Location(40.768495, -73.944961); // the center of NYC
  map.zoomAndPanTo(NYCLocation, 12); // at zoom level 12
  map.setPanningRestriction(NYCLocation, 10);// Panning restrictions, in km
  map.setZoomRange(10, 17);// Zooming restrictions
  map.setTweening(true);// animations between different zoom levels
}

void parseData() {
  int c = 0; // count the line
  // java environment: avoid potential crash
  // try - catch
  try {
    // ! cannot use for-loop: do not know the length of data
    // because the data is not in the memory
    // use the while-loop
    String ln;
    // BufferedReader will read one line each time
    while ( (ln = myReader.readLine ()) != null) {
      if (c>0 && c<8048) {
        Building b = new Building();
        buildings.add(b);

        // regular expressions: splitting a comma-separated string but ignoring commas in quotes
        String[] cols = ln.split(",(?=([^\"]*\"[^\"]*\")*[^\"]*$)"); // split the string into array

        b.owner = cols[4];//"Owner");
        b.phasingOut6Oil = cols[7];//"Deadline for phasing out #6 oil (i.e. data of next DEP permit renewal after July 1 2012)");
        b.boilerModel = cols[8];//"Boiler Model");
        b.boilerNum = float(cols[9]);//"Number of identical boilers");
        b.boilerCap = float(cols[10]);//"Boiler capacity (Gross BTU)");
        b.boilerInsDate = int(cols[11]);//"Boiler Installation Date"); // year
        b.boilerEndDate = b.boilerInsDate + 35; //assuming 35 year average useful life
        b.boilerFuel = cols[13];//"Primary Fuel"); // #6

        b.boilerHighCosumGallon = float(cols[17]);//"Total Estimated Cosumption - High Estimate (Gallons) ");
        b.boilerLowCosumGallon = float(cols[18]);//"Total Estimated Cosumption - Low Estimate (Gallons) ");
        b.boilerHighCosumMMBTUs = float(cols[19]);//"Total Estimated Cosumption - High Estimate (MMBTUs) ");// http://www.energyvortex.com/energydictionary/british_thermal_unit_(btu)__mbtu__mmbtu.html
        b.boilerLowCosumMMBTUs = float(cols[20]);//"Total Estimated Cosumption - Low Estimate  (MMBTUs) ");
        b.avgCosumGallon = (b.boilerHighCosumGallon + b.boilerLowCosumGallon)/2.0;

        b.boilerComplyLaw = cols[21];//"Needs to comply with Greener Greater Buildings Laws?"); 
        b.boilerComplyLawDeadline = cols[22];//"Deadline for complying with Audit and Retrocommissioning Law");

        b.buildingType = cols[23];//"Building Type");
        b.buildingArea = float(cols[25]);//"Total area of buildings on lot");
        b.buildingFloors = float(cols[27]);//"Number of floors");
        b.buildingResidentialUnits = float(cols[28]);//"Number of residential units"); // some are 0
        b.buildingTotalUnits = int(cols[29]);//"Number of total units");// at least 1
        b.buildingYearCons = int(cols[30]);//"Year constructed");
        b.avgCosumGallonPerUnit = b.avgCosumGallon/b.buildingTotalUnits;

        // get the lon/lat from the string: "2840 BAILEY AVENUE Bronx, NY 10463 (40.874331271215354, -73.9048664936111)"
        String address = cols[1];
        if (address.length() != 0) {
          // str.substring(beginIndex_inclusibe, endIndex_exclusive)
          b.address = address.substring(address.indexOf("\"")+1, address.indexOf("("));
          String stemp = address.substring(address.indexOf("(")+1, address.indexOf(")"));
          float[] ftemp = float(stemp.split(","));
          b.lonLat.x = ftemp[1];
          b.lonLat.y = ftemp[0];
          b.buildingMarker = new SimplePointMarker(new Location(b.lonLat.y, b.lonLat.x));

          if (c == 80) {
            // print sth simple to let you know the Processing is working
            // avoid print the content in each line
          }
        }
        b.init();
      }
      c++;
      // set up the location
      //nyc: -74.047285,40.679548,-73.907,40.882214
      // my area: -74.09329,40.637616,-73.816019,40.794681
      PVector topleft = new PVector(-74.09329, 40.794681);
      PVector bottomright = new PVector(-73.816019, 40.637616);
      placeVisits(topleft, bottomright);
      setTimes();
    }
  }
  catch(Exception e) {
    println("READER FAILED." + e + "; -line:"+c);
  }
}

void findConsumer() {
  for (Building b : buildings) {
    int tempB = int(b.avgCosumGallonPerUnit);
    if (tempB!=0 && tempB > biggestConsumer) {
      biggestConsumer = tempB;
      biggestConsumerID = buildings.indexOf(b);
    }
    if (tempB!=0 && tempB < smallestConsumer ) {
      smallestConsumer = tempB;
      smallestConsumerID = buildings.indexOf(b);
    }
  }
  println("max id:"+biggestConsumerID+" is:"+biggestConsumer+" -- min id:"+smallestConsumerID+" is:"+smallestConsumer);
}

void setTimes() {
  for (Building b : buildings) {
    // ! convert to float to get the fraction, otherwise, it would be 0.0
    b.timeFraction = ((float) (b.buildingYearCons - 1845)) / 170.0;
  }
}

// pass the top-left and botom-right
void placeVisits(PVector tl, PVector br) {
  for (Building b : buildings) {
    // map the position to the screen scope
    b.pos.x = map(b.lonLat.x, tl.x, br.x, 0, width);
    b.pos.y = map(b.lonLat.y, tl.y, br.y, 0, height);
    b.tpos.x = map(b.lonLat.x, tl.x, br.x, 0, width);
    b.tpos.y = map(b.lonLat.y, tl.y, br.y, 0, height);
  }
}

void mousePressed() {
  //saveFrame("Time_Space_01-####.png");
}
// 

