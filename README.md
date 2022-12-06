# LaserMat
*LaserMat* is a computer vision library written in MatLab, thought for laser triangulation-based systems. It allows to calibrate the system using [Tsai] calibration algorithm, to conveter the coordinate from the image referece system to the world referece system and vice-versa. Furthermore, it contains some filters for image and laser processing.

This collection of methods was used during the master thesis in computer engineering at the [University of Padua]. If you use this library, please cite:

Badan, A. (2017). *Measurement system for profile and diameter of railway wheels. Estimate of an accuracy of laser-camera triangulation sensors*

> __ATTENTION__: this repository is no longer mantained. Missing images and library components have been lost. I'm sorry for the inconvinient.

### Main packages
| Package | Description |
| ------- | ----------- |
|*calibration*| The package allows to calibrate the triangulation system, using the coplanar version of [Tsai]. Furthermore, there are some methods for the reconstruction of the grid, starting from a series of target aquisitions. |
|*coordinates*| This packages contains all the method needed to the projection from different reference systems. |
|*evaluation*| It contains all the methods for the estimation of the implemented model. |
|*examples*| It contains some examples. |
|*fex*| Collection of methods taken from [MatLab community].|
|*filters*| Set of custom image filters. |
|*gui*| Simple interface for use the model.|
|*math*| It contains some custom math function. |
|*signals*| It contains custom signals, needed to approximate working conditions to perform our analysis.|
|*subfilters*| Filters to increase the precision of laser spot detection, with subpixel approximation. |
|*tools*| Various method. |
|*wpms*| This package contains some methods WMPS-like system, and some tool to convert my data to MatLab data. |

### Documentation
Each method is fully documentated. To see the documentation, you have to use the `help` command in MatLab shell. Furthermore, there are some examples in the *scripts* directory. To execute a simple gui, lauch the `LaserMatGui.m` file.

This is an exaple of how use the laser extractor function
```
rgb_image = imread('./examples/e2-laser/figure.bmp');
gs_image = rgb2gray(rgb_image);
filtered_image = thresholdFilter(gs_image, threshold);

laser = findLaser(filtered_image, 200, false, true);
filtered_laser = centerOfMass(filtered_image, laser, 11);

figure;
plot(filtered_laser(:,1), filtered_laser(:,2), '.r');
```

### Installation
To use this library is sufficient to add to the enviroment path the directories containing the library. Look at the [MatLab documentation] for more information.
Otherwise, you can use the `addAll.m` script to add all packages.

[Tsai]: http://www.dca.fee.unicamp.br/~clesio/ia867/referencias_e_notas_aula/CC_TSAI_87.pdf
[MatLab documentation]: https://it.mathworks.com/help/matlab/ref/addpath.html
[University of Padua]: http://www.unipd.it/
[MatLab community]: https://it.mathworks.com/matlabcentral/?s_tid=gn_mlc
