/*
 * Analyze Mark_and_Find_XXX images (x,y,z confocal scans)
 *
 *
 * Author: Igor Segota
 * Date: 2015-01-08
 *
 */

 /*
  * workingDirectory should only contain directories of the form
  * Mark_and_Find_XXX where XXX is the number with padded zeros.
  *
  */
workingDirectory = "\\Users\\Igor\\Dropbox\\invitro-gut\\2015-08-07_dlac_dgal\\Experiment\\";
// end working Directory with '\\'

numberOfStrains = 2;
colorForAnalysis = "green"; // this is only used if numberOfStrains==1
brightnessMin = 0;
brightnessMax = 138;
fileEndExtension = "_ch00.tif";

// These thresholds 83-255 seem fine for both GFP (7.6%) and mCh (10% laser) on plasmids
thresholdMin  = 83;
thresholdMax  = 255;
// For GFP I used 0-138
// For mCh I can use 0-83 (they pop out nicely)

timePointFolders = getFileList(workingDirectory);
Array.show(timePointFolders);
waitForUser("Derp.");

// ImageJ setup
run("Set Measurements...", "area centroid redirect=None decimal=2");

/* Index Legend:
 * ------------
 *  j is time index (from 1 to timePointFolders.length)
 *  p is the xypositionIndex (from 1 to positionFolders.length)
 *  f is the index of files but also non-images
 *  z is the zpositionIndex (from 1 to positionFiles.length)
 *    (just images from f)
 */

firstCurrentResultRow = 0;


// do this for every other time point j=j+2 (later analyze everything j=j+1)
for (j=1; j<=timePointFolders.length; j=j+1) {

	print("Time point:"+j+"/"+timePointFolders.length);
	/* do this for each time point folder
	 *
	 *  Just leave a position index, since we can't load
	 *  XML files here and extract the numbers.
	 *  we will read the exact x,y,z coordinates in R and
	 *  match them with the position index/
	 *
	 */
	positionFolders = getFileList(workingDirectory+timePointFolders[j-1]+"\\");

	for (p=1; p<=positionFolders.length; p++) {

		currentDirectory = workingDirectory+timePointFolders[j-1]+"\\"+positionFolders[p-1]+"\\";
		positionFiles = getFileList(currentDirectory);

		// do this for each individual image
		z=1;

		for (f=1; f<=positionFiles.length; f++) {

			// only load files that are TIFF images
			// make a note of time and z coordinate too
			if (endsWith(positionFiles[f-1], fileEndExtension)) {

				/* Image processing:
				 *  do this for each image.
				 */

				// Open image and extract image title
				open(currentDirectory+positionFiles[f-1]);
				currentImageTitle = getTitle();

				// Split into RGB channels and keep only red or green
				run("Split Channels");
				if (colorForAnalysis == "red") {
					selectWindow(currentImageTitle+" (green)");
					close();
					selectWindow(currentImageTitle+" (blue)");
					close();
					selectWindow(currentImageTitle+" (red)");
				}
				else if (colorForAnalysis == "green") {
					selectWindow(currentImageTitle+" (red)");
					close();
					selectWindow(currentImageTitle+" (blue)");
					close();
					selectWindow(currentImageTitle+" (green)");
				}
				else {
				}
				// Smooth the image
				run("Smooth");

				// Remove scale information
				run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");

				// Adjust brightness / contrast
				setMinAndMax(brightnessMin, brightnessMax);
				run("Apply LUT");

				// Threshold the image
				setThreshold(thresholdMin, thresholdMax);
				run("Convert to Mask");

				// Analyze particles and add to Results table
				run("Analyze Particles...", "size=2-20 display");
				// 2-20 for mCh
				// 2-15 for GFP used to, but do 2-20 next


				// Add fake particle to each count, so we have some
				// entry for pictures where there are no particles.
				/* Update the results table with labels for this
				 *  image (xypositionIndex and zpositionIndex).
				 *
				 *  The results table is updated after we do
				 *  Analyze Particles for each individual image.
				 */

				for (k=firstCurrentResultRow; k<nResults; k++) {
					setResult("tFrameTimeIndex", k, j);
					setResult("xyFramePositionIndex", k, p);
					setResult("zFramePositionIndex", k, z);
				}

				setResult("Area", nResults, 1000);
				setResult("X", nResults-1, 0.0);
				setResult("Y", nResults-1, 0.0);
				setResult("tFrameTimeIndex", nResults-1, j);
				setResult("xyFramePositionIndex", nResults-1, p);
				setResult("zFramePositionIndex", nResults-1, z);


				firstCurrentResultRow = nResults;
				z++;

				// Close the image
				close();
			} // end if file ends with .tif

		} // end do this for each individual image

	} // end do this for each time point folder


} // end do this for each time point

// Save Results to file manually
