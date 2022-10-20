//Macro to define ROIs for subsequent batch analysis//
indir = getDirectory("Choose a directory for input CZIs");
outdir_roi = getDirectory("Choose a directory for output ROIs");
outdir_intensity = getDirectory("Choose a directory for output CSVs");
indirlist = getFileList(indir);

// Specify channels to measure:
channel_1_number = 1;
channel_1_name = "H2BRFP";
channel_2_number = 3;
channel_2_name = "Dex488";

// Define measurement parameters
run("Set Measurements...", "area mean integrated display redirect=None decimal=3");

//setBatchMode(false);

for(i=0;i<indirlist.length;i++){
	run("Bio-Formats Windowless Importer", "open=" + indir + indirlist[i]);

	//Learn file name, prepare file and Fiji for analysis
	name=File.nameWithoutExtension;
	//waitForUser("Find equatorial slice", "Duplicate desired slice.");
	
	rename("A");
	setTool("freehand");
	run("Median...", "radius=1 slice");
	run("Channels Tool...");
	Stack.setDisplayMode("composite");
	Stack.setChannel(1);
	run("Magenta");
	resetMinAndMax();
	run("Enhance Contrast", "saturated=0.3");
	Stack.setChannel(2);
	run("Grays");
	resetMinAndMax();
	run("Enhance Contrast", "saturated=0.45");
	Stack.setChannel(3);
	run("Cyan");
	resetMinAndMax();
	setMinAndMax(100, 15000);
	Stack.setActiveChannels("111");

	//Define ROIs Manually (background, then each cell for analysis)
	waitForUser("Background ROI", "Draw background ROI then press ok.");
	roiManager("Add");
	roiManager("Select",0);
	roiManager("Rename","background");
	roiManager("Show All");
	waitForUser("ROIs", "Draw ROI for each desired location, and add to ROI manager with 't', then press ok after all ROIs drawn.");
	
	//Save out ROIs
	//roi_dir = getDirectory("Choose a directory to save ROI sets.");
	roiManager("Save", outdir_roi+name+".zip");
	roiManager("show all");

	// Split channels and measure intensity from both channels
	run("Split Channels");
	selectWindow("C" + channel_1_number + "-A");
	rename(channel_1_name);
	resetMinAndMax;
	roiManager("Deselect");
	roiManager("Measure");
	selectWindow("C" + channel_2_number + "-A");
	rename(channel_2_name);
	resetMinAndMax;
	roiManager("Deselect");
	roiManager("Measure");
	saveAs("Results", outdir_intensity+name+"_Intensity.csv");
	
			
	//Close unnecessary windows from last analysis
	run("Close All");
	if (isOpen("Results")) { 
	         selectWindow("Results"); 
	         run("Close"); 
	    } 
	if (isOpen("Summary")) { 
	         selectWindow("Summary"); 
	         run("Close"); 
	    } 
	if (isOpen("ROI Manager")) { 
	         selectWindow("ROI Manager"); 
	         run("Close"); 
	    } 
}