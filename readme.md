# _In-vitro_ gut bacterial ecology

<p align=center>
<img src="https://github.com/igor25/invitro-gut/blob/master/images/minifluidic_device.jpg" />
</p>

This is a collection of image analysis and plotting scripts for the in-vitro gut project. In this project, we grew bacteria in a fancy rubber tube that resembles a mouse gut. The tube has a ceiling that can depress and simulate gut contractions. We grew two synthetic strains of bacteria, termed Producer (P) and Consumer (C), that approximate a more complex bacterial gut metabolism: P eats complex nutrients coming into the gut, and C only eats simple nutrients left over from P.

The code in this repo:

* Arduino code is in the directory ``arduino-code``. To program Arduino, load the .ino file into the Arduino Software then Upload to Arduino MEGA.

* ImageJ script for image processing and particle counting ``image-processing-macro_imagej.ijm``. This analyzes a series of images, performs image processing (extracting color channels, adjusting brightness, smoothing, thresholding), and outputs a tab-delimited text file that is input to R.

* R code for summarizing ImageJ tab-delimited output and plotting it ``plot_imagej_output.R``. Input is a tab-delimited file from the previous ImageJ step and output are the plots and summarized data.

* Python code for plotting the summarized output from R ``python-matplotlib-plots/*.*``. Use matplotlib to generate nice PDF plots.

## Reference:

J. Cremer\*, I. Segota\*, C. Yang, M. Arnoldini, J.T. Sauls, Z. Zhang, E. Gutierrez, A. Groisman & T. Hwa, The effect of flow and peristaltic mixing on bacterial growth in a gut-like channel, under review for Proc. Natl. Acad. Sci. USA (2016)

\* equal contribution
