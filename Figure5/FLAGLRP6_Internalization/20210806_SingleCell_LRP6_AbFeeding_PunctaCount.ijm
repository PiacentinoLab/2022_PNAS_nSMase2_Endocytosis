//////////////////////////////////////
// Define directories (User-Input):
//indir_czi = getDirectory("Choose a directory for input CZIs");
//indir_roi = getDirectory("Choose a directory for input ROIs");
//outdir_puncta = getDirectory("Choose a Directory for output puncta CSVs");
//outdir_intensity = getDirectory("Choose a Directory for output intensity CSVs");
//outdir_ROI = getDirectory("Choose a Directory for output ROIs");
//indir_czi_list = getFileList(indir_czi);
//indir_roi_list = getFileList(indir_roi);

// Define directories (Hard-Coded):
indir_czi = getDirectory("home")+"Desktop//20210813_NCExplant_LRP6_AbFeeding_SMPD3MO//czi//"
indir_roi = getDirectory("home")+"Desktop//20210813_NCExplant_LRP6_AbFeeding_SMPD3MO//rois//"
outdir_puncta = getDirectory("home")+"Desktop//20210813_NCExplant_LRP6_AbFeeding_SMPD3MO//puncta_csvs//"
outdir_masks = getDirectory("home")+"Desktop//20210813_NCExplant_LRP6_AbFeeding_SMPD3MO//masks//"
indir_czi_list = getFileList(indir_czi);
indir_roi_list = getFileList(indir_roi);

//////////////////////////////////////

// Define measurement parameters
run("Set Measurements...", "area mean integrated display redirect=None decimal=3");

// Toggle batch mode
setBatchMode(true);

if (isOpen("ROI Manager")) { 
         selectWindow("ROI Manager"); 
         run("Close"); 
    } 


// Start for loop to go through each image for analysis
for(i=0;i<indir_czi_list.length;i++){
	// Open image
	run("Bio-Formats Windowless Importer", "open=" + indir_czi + indir_czi_list[i]);
	name=File.nameWithoutExtension;
	rename("ActiveImage");
	run("Split Channels");
	print("Processing: " + name);
	// Open ROIs
	roiManager("open", indir_roi + name + ".zip");

	// Prepare image for thresholding
	selectWindow("C2-ActiveImage");
	rename("threshA");
	resetMinAndMax();
	run("Median...", "radius=3");
	run("8-bit");

//// Threshold image //// 
	// Automatic:
	setThreshold(40, 255);
	run("Convert to Mask", "method=Default background=Dark calculate black");
	run("Watershed");

//////////////////////////////////////

	// Loop through ROIs and count puncta within each ROI (SUMMARY)
	roiManager("Show All");
	saveAs("JPEG", outdir_masks+name+"_Mask.jpg");
	for(roi=1;roi<roiManager("count");roi++){
		selectWindow("threshA");
		run("Duplicate...", "title=temp");
		rename(roi);
		roiManager("Select", roi);
		run("Analyze Particles...", "size=0.1-7.50 show=Nothing summarize exclude");
		close();
	}

//	waitForUser("How does it look?");
	saveAs("Results", outdir_puncta+name+"_Puncta.csv");
	
	if (isOpen(name+"_Puncta.csv")) { 
	         selectWindow(name+"_Puncta.csv"); 
	         run("Close"); 
	    } 


//////////////////////////////////////
	
	// Close out analysis in preparation for the next run
	roiManager("Deselect");
	roiManager("Delete");
	if (isOpen("ROI Manager")) { 
	         selectWindow("ROI Manager"); 
	         run("Close"); 
	    } 
	if (isOpen("Results")) { 
	         selectWindow("Results"); 
	         run("Close"); 
	    } 
	if (isOpen("Summary")) { 
	         selectWindow("Summary"); 
	         run("Close"); 
	    } 
	if (isOpen(name+"_Puncta.csv")) { 
	         selectWindow(name+"_Puncta.csv"); 
	         run("Close"); 
	    } 
run("Close All");
}

