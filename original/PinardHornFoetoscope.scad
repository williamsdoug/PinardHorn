/*	Printable Pinard Horn Foetoscope
	by Philip Hands <phil@hands.com>
	with additional contributions from:
		aubenc@thingiverse

	Copyright (C) 2012, GPL v3 or later

In a concession to 3D printing, the listening end of this Foetoscope
starts off with a flat disk, rather than a gentle curve.  This seems
to suit the use of support material better, which turned out to be
needed for most of the shapes I tried -- it seems to work anyway
though -- further testing is almost certainly worthwhile if you want
to discover the best possible shape for a foetoscope, as this was done
by eye, not really knowing the underlying science.

aubenc's contribution (other than making the comments much more explicit)
is mainly to do with printing without automatically generated support material,
but instead having a pillar under the horn, and relying on bridging to form the disk.

The original wall thickness was set as t=2, which works well on my Prusa, which
(perhaps because I'm running it too hot) struggles with thinner walls, but aubenc
apparently gets away with t=1.05

The BezConicOffset() module is closely based on BezConic() by Don B,
which he released into the Public Domain in 2011.

  http://www.thingiverse.com/thing:8931

with the addition of a cheap & nasty offset vector to give the thickness
This should probably be normal to the surface, but this worked, and I
don't have forever before my test subject becomes unavailable :-)
*/

/* ******************* Parameters *************************************** */

    T=2;  // wall Thickness
    L=106;   // total length above the base

    F=[];
    //F=["support"]; // set flags:
                   // "support" - add a support cylinder, which if your printer
                   //  is good at bridging should be enough without added support

/* ******************* Modules ****************************************** */

PinardHornFoetoscope(length=L, thickness=T, flags=F);   // The thing!
// testSize(length=L, thickness=T, flags=F);            // Check length
// testBase(length=L, thickness=T, flags=F);            // Useful to do a quick print test of the base,
// baseSection(length=L, thickness=T, flags=F);         // Just in case you'd like to tweak the design
                          //  added support cylinder in PinardHornFoetoscope()
                          //  module


/* ******************* Code ********************************************* */

module PinardHornFoetoscope(length=106, baseheight=5, thickness=2, flags=[])
{
  union() {
    rotate_extrude($fn = 60, convexity = 10)
        foetoscope_polygon(length=length, baseheight=baseheight, thickness=thickness, flags=flags);

    for (f = flags) {
      if ("support"==f) {
        // FIXME: this lot isn't parameterised
        translate([0,5.5,0]) cube([0.6,12,baseheight]);
        translate([0,-17.5,0]) cube([0.6,12,baseheight]);
        translate([12,-12,0]) cube([0.6,24,baseheight]);
        translate([-12,-12,0]) cube([0.6,24,baseheight]);
        translate([7,-15,0]) cube([0.6,30,baseheight]);
        translate([-7,-15,0]) cube([0.6,30,baseheight]);
        translate([0,-10,0]) cube([0.6,20,baseheight]);
        rotate([0,0,90]) translate([0,-13,0]) cube([0.6,25,baseheight]);     
      }
    }
  }
}

module testSize(length=106, baseheight=5, thickness=2, flags=[])
{
    PinardHornFoetoscope(length=length, baseheight=baseheight, thickness=thickness, flags=flags);
    translate([0,0,l/2]) %cube(size=[70,70,l], center=true);
}

module testBase(length=106, baseheight=5, thickness=2, flags=[])
{
    intersection() {
        PinardHornFoetoscope(length=length, baseheight=baseheight, thickness=thickness, flags=flags);
        cube(size=[70,70,20], center=true);
    }
}

module baseSection(length=106, baseheight=5, thickness=2, flags=[])
{
    difference()
    {
        testBase(length=length, baseheight=baseheight, thickness=thickness, flags=flags);
        translate([0,-35,0]) cube(size=[70,70,70], center=true);
    }
}

module BezConicOffset(p0,p1,p2,steps=5,offset=[-1,-1]) {

	stepsize1 = (p1-p0)/steps;
	stepsize2 = (p2-p1)/steps;

	for (i=[0:steps-1]) {
		assign(point1 = p0+stepsize1*i) 
		assign(point2 = p1+stepsize2*i) 
		assign(point3 = p0+stepsize1*(i+1))
		assign(point4 = p1+stepsize2*(i+1))  {
			assign( bpoint1 = point1+(point2-point1)*(i/steps) )
			assign( bpoint2 = point3+(point4-point3)*((i+1)/steps) )
			assign( bpoint3 = point1+(point2-point1)*(i/steps)+offset )
			assign( bpoint4 = point3+(point4-point3)*((i+1)/steps)+offset )
                              {
				polygon(points=[bpoint1,bpoint2,bpoint4,bpoint3]);
			}
		}
	}
}

module foetoscope_polygon(length=106, thickness=2,baseheight=5, flags=[]) {

   l=length;
   t=thickness;
  
    // base dimensions
    bx0=20;
    bx1=bx0+2;
    bx2=bx1+5;
    by1=baseheight;
    by2=by1+1.6;

    // trumpet dimensions
    ty0=by1;
    ty1=l-21;
    ty2=ty1+20;
    tx0=6;
    tx1=20;

    // points for the trumpet
    p0=[tx0,ty0];
    p1=[tx0,ty1];
    p2=[tx1,ty2];

    // support pillar dimensions
    sx=tx0-t+1;
    sy=by1+1;

    // trumpet
    BezConicOffset (p0,p1,p2,30,[-t,0]);

    basepoints = [
      [bx2,0],
      [bx1-t,0],
      [bx1-t-by1/2,by1],
      [tx0-t,by1],
      [tx0-0.1,by2+4],
      [tx0+2,by2],
      [bx1-by1/2,by2],
      [bx1,t],
      [bx2,t],
    ];

    // base
    polygon(points=basepoints);

    // rounding for base
    translate([bx2,t/2]) circle(t/2,$fn=20);
    // rounding for trumpet
    translate(p2+[(-0.5-t)/2,t/5]) circle((t+0.5)/2,$fn=20);

    for (f = flags) {
        if ("support"==f) {
            polygon(points=[[0,0],[sx,0],[sx,sy],[0,sy]]);
        }
    }
}

/* ******************* End ********************************************** */
