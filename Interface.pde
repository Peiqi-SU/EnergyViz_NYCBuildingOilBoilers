int yoff = 1;
int yoffImg = 1;
boolean vibrationIcon = false;
float noiseNum = 1;
void render() {
  // draw the bg
  noStroke();
  fill(0, 0, 0, 200);
  rect(0, height-height/20-49, width, height/20+49);
  // draw the title
  textAlign(CENTER);
  textFont(font, 22);
  noStroke();
  fill(0, 0, 100, 255);
  text("Fuel Consumption of Buildings in NYC", width/2, height-height/20-27);

  // draw the date mark from 1848 to 2013 (165years), 18 lines, from 1845 to 2015
  for (int i = 0; i < 17; i++) {
    textAlign(CENTER);
    textFont(font, 12);
    stroke(0, 0, 100, 255);
    strokeWeight(2);
    line(i*(width-border*2)/16+border, height - height/20 +yoff, i*(width-border*2)/16+border, height+yoff);

    noStroke();
    fill(0, 0, 100, 255);
    text(1850+i*10, i*(width-border*2)/16+border, height - height/20-8+yoff);
  }

  // draw the time fly bar
  // float timefly = (float) frameCount / 1000; // map(mouseX, 0, width, 0, 1);
  timefly += 0.01;
  stroke(0, 0, 100, 255);
  strokeWeight(1);
  fill(0, 0, 100, 50);
  rect(border, height - height/20+yoff, timefly * (width-border*2), height/20);

  // draw the img
  image(imgEg, 0, height +1 - yoffImg);
  // draw the vibration icon
  buildings.get(1).emit(672, 663);
  fill(noise(noiseNum)*140, 75, 75, 200);
  noiseNum += 0.01;
  ellipse(672, 663, 4, 4);

  textAlign(LEFT);
  textFont(fontSmall, 14);
  noStroke();
  fill(0, 0, 100, 255);
  text("Everage Estimated Oil Cosumption", 172, height-height/20 + 58 - yoffImg);
  text("of per Unit in a Building (Gallons)", 172, height-height/20 + 78 - yoffImg);

  if (timefly > 1) {
    timefly = 1;
    // time line donw
    if (yoff<64) {
      yoff *=2;
    }
    else {
      yoff = 64;
      // eg img up
      if (yoff == 64 && yoffImg <56) {
        yoffImg *=2;
      }
      else {
        yoffImg = 56;
        vibrationIcon = true;
      }
    }
  }
}

