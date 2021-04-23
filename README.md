# tubule-tracker
Code to track fibre-like objects from fluorescence microsopy videos. Tracking is available for a point on the fibre as well as tracking of the whole contour.
There are three different tracking/analysis methods in the three folders: 

  1) Point Tracking and MSD Calculation
  2) Contour Tracking
  3) Fourier Analysis

##  Point Tracking and MSD Calculation
The point tracking code requires the user to define a line perpendicular to the fibre and then it tracks the central position of the tubule along this line by fitting the intensity profile. The mean squared displacement of this track is calculated and fit with a power law. Based on previous work by Georgiades et al (https://doi.org/10.1038/s41598-017-16570-4)


##  Contour Tracking
Contours of fibre-like objects can be tracked over all frames of a video using this code. The user must click on the start and end points of a fibre in the first frame, but the remaining frames are tracked automatically. This code is heavily based on FiberApp, open source software by Usov & Mezzenga (https://doi.org/10.1021/ma502264c, https://github.com/ivan-usov/FiberApp). The average position of the tubule over time (or its backbone) is found and the variance and skewness of each position along the backbone is calculated. Significant skewness on any of these points indicates driven motion.

##  Fourier Analysis
Contours found using the Contour Tracking code above can be decomposed into Fourier modes using this code. The amplitude of each mode is plotted over time to show the curvature dynamics. Based on work by Cox et al (https://doi.org/10.1021/acs.langmuir.8b03334).
