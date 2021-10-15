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
indir_czi = getDirectory("home")+"Desktop//20210804_NCExplant_Tf633Assay_GW4869;Dynasore//czi//"
indir_roi = getDirectory("home")+"Desktop//20210804_NCExplant_Tf633Assay_GW4869;Dynasore//rois//"
outdir_puncta = getDirectory("home")+"Desktop//20210804_NCExplant_Tf633Assay_GW4869;Dynasore//puncta_csvs//"
indir_czi_list = getFileList(indir_czi);
indir_roi_list = getFileList(indir_roi);

//////////////////////////////////////

// Define measurement parameters
run("Set Measurements...", "area mean integrated display redirect=None decimal=3");

// Toggle batch mode
setBatchMode(true);

// Start for loop to go through each image for analysis
for(i=0;i<indir_czi_list.length;i++){
	// Open image
	run("Bio-Formats Windowless Importer", "open=" + indir_czi + indir_czi_list[i]);
	name=File.nameWithoutExtension;
	rename("A");
	print("Processing: " + name);
	// Open ROIs
	roiManager("open", indir_roi + name + ".zip");
	roiManager("show all");

	// Prepare image for thresholding
	run("Duplicate...", "duplicate channels=4");
	selectWindow("A");
	close();
	rename("A");
	run("Duplicate...", " ");
	rename("threshA");
	resetMinAndMax();
	run("Median...", "radius=2");
	run("8-bit");

	//// Threshold image //// 
	// Automatic:
	run("Auto Local Threshold", "method=Bernsen radius=25 parameter_1=0 parameter_2=0 white"); 

//////////////////////////////////////

	// Loop through ROIs and count puncta within each ROI (SUMMARY)
	roiManager("Show All");
	for(roi=1;roi<roiManager("count");roi++){
		selectWindow("threshA");
		run("Duplicate...", "title=temp");
		rename(roi);
		roiManager("Select", roi);
		run("Analyze Particles...", "size=0.25-5.00 show=Nothing summarize exclude");
		close();
	}
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

