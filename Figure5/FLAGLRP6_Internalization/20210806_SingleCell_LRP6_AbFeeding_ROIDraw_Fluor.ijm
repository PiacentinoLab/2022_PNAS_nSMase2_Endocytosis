//////////////////////////////////////
//Macro to define ROIs manually and save out files for later batch puncta counting macros//

// Prepare for analysis: define directories, learn file name, etc 
roi_dir = getDirectory("home")+"Desktop//20210813_NCExplant_LRP6_AbFeeding_SMPD3MO//rois//"
name=File.nameWithoutExtension;
rename("ActiveImage");
setTool("freehand");

//////////////////////////////////////
// Display image for ROI definition
run("Channels Tool...");
Stack.setDisplayMode("composite");
Stack.setChannel(1);
run("Red");
//run("Enhance Contrast", "saturated=0.3");
setMinAndMax(0, 24000);
Stack.setChannel(2);
run("Green");
//run("Enhance Contrast", "saturated=0.3");
setMinAndMax(100, 7000);
Stack.setChannel(3);
run("Magenta");
//run("Enhance Contrast", "saturated=0.3");
setMinAndMax(500, 7500);
Stack.setChannel(4);
run("Grays");
//run("Enhance Contrast", "saturated=0.3");
//setMinAndMax(6615, 13728);
Stack.setActiveChannels("1111");

//////////////////////////////////////
// Define ROIs Manually (background, then each cell for analysis)
waitForUser("Background ROI", "Draw background ROI then press ok.");
roiManager("Add");
roiManager("Select",0);
roiManager("Rename","background");
Stack.setActiveChannels("1110");
roiManager("Show All");
waitForUser("ROIs", "Draw ROI for each desired location, and add to ROI manager with 't', then press ok after all ROIs drawn.");

// Save out ROIs
roiManager("Save", roi_dir+name+".zip");

//////////////////////////////////////
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
