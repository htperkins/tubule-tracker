# tubule-tracker
Code to track fibre-like objects from fluorescence microsopy videos. Tracking is available for a point on the fibre as well as tracking of the whole contour.
There are three different tracking/analysis methods in the three folders: 

  1) Point Tracking and MSD Calculation
  2) Contour Tracking
  3) Fourier Analysis

##  Point Tracking and MSD Calculation
The point tracking code requires the user to define a line perpendicular to the fibre and then it tracks the central position of the tubule along this line by fitting the intensity profile. The mean squared displacement of this track is calculated and fit with a power law. Based on previous work by Georgiades et al (https://doi.org/10.1038/s41598-017-16570-4) and uses existing MATLAB code: https://www.mathworks.com/matlabcentral/fileexchange/66136-easykriging and https://uk.mathworks.com/matlabcentral/fileexchange/42885-nearestspd.


##  Contour Tracking
Contours of fibre-like objects can be tracked over all frames of a video using this code. The user must click on the start and end points of a fibre in the first frame, but the remaining frames are tracked automatically. This code is heavily based on FiberApp, open source software by Usov & Mezzenga (https://doi.org/10.1021/ma502264c, https://github.com/ivan-usov/FiberApp). The average position of the tubule over time (or its backbone) is found and the variance and skewness of each position along the backbone is calculated. Significant skewness on any of these points indicates driven motion.

##  Fourier Analysis
Contours found using the Contour Tracking code above can be decomposed into Fourier modes using this code. The amplitude of each mode is plotted over time to show the curvature dynamics. Based on work by Cox et al (https://doi.org/10.1021/acs.langmuir.8b03334).


## Licenses
The license for the original **FiberApp** software is as follows:
Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Publication of any type of results based on the use of this open source code legally requires citation to the original publication: Usov, I and Mezzenga, R. FiberApp: an Open-source Software for Tracking and Analyzing Polymers, Filaments, Biomacromolecules, and Fibrous Objects. Macromolecules, 2015, 49, 1269-1280.

3. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


The license for **easyKriging** software is as follows:
Copyright (c) 2018, Jack
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


The license for **nearestSPD** software is as follows:
Copyright (c) 2013, John D'Errico
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
