//////////////////////////////////////
//Macro to define ROIs and measure Cellular Fluorescence//

// Prepare for analysis: define directories, learn file name, etc 
roi_dir = getDirectory("home")+"Desktop//20210807_NCExplant_Tf633Assay_SMPD3MO;SMPD3FLAG;Rescue//rois//"
csv_dir = getDirectory("home")+"Desktop//20210807_NCExplant_Tf633Assay_SMPD3MO;SMPD3FLAG;Rescue//intensity_csvs//"
name=File.nameWithoutExtension;
rename("ActiveImage");
setTool("freehand");

//////////////////////////////////////
// Display image for ROI definition
run("Channels Tool...");
Stack.setDisplayMode("composite");
Stack.setChannel(1);
run("Green");
run("Enhance Contrast", "saturated=0.3");
Stack.setChannel(2);
run("Red");
run("Enhance Contrast", "saturated=0.3");
Stack.setChannel(3);
run("Grays");
run("Enhance Contrast", "saturated=0.6");
Stack.setActiveChannels("111");

//////////////////////////////////////
// Define ROIs Manually (background, then each cell for analysis)
waitForUser("Background ROI", "Draw background ROI then press ok.");
roiManager("Add");
roiManager("Select",0);
roiManager("Rename","background");
roiManager("Show All");
waitForUser("ROIs", "Draw ROI for each desired location, and add to ROI manager with 't', then press ok after all ROIs drawn.");

// Save out ROIs
roiManager("Save", roi_dir+name+".zip");

//////////////////////////////////////
// Measure Tf633 intensity
run("Set Measurements...", "area mean integrated display redirect=None decimal=3");
run("Split Channels");
selectWindow("C1-ActiveImage");
roiManager("Show All");
roiManager("Deselect");
roiManager("Measure");
saveAs("Results", csv_dir+name+"_Intensity.csv");

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
