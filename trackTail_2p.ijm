input = getDirectory("Input Directory");
suffix = ".avi";
processFolder(input);

function processFolder(input) {
	list = getFileList(input);
	j = 0;
	//param = newArray(48,255,200,0);
	for (i = 0; i < list.length; i++) {
		if(endsWith(list[i], suffix)){
			if(j == 0){
				param = first_trackTail(input,list[i]);
				run("Close All");
				j = 1;
			}
			else{
				param = others_trackTail(input,list[i], param);
				run("Close All");
			}
		}
	}
}
	
function first_trackTail(input, file){
	main_output = input + "/tail";
	if(File.exists(main_output) != 1){
		File.makeDirectory(main_output);
	}
	// open file
	open(input + file);
	orig = getTitle();
	origname = replace(orig,".avi","");

	setTool("rectangle");
	makeRectangle(0, 0, 29, 18);
	//run("Specify...", "width=100 height=100 x=88 y=122 slice=1");
	waitForUser("Pause", "Select region of tail"); // Ask for input ROI
	
	// Save ROI parameters
	saveAs("XY Coordinates", main_output + "/Crop_XY.txt");
	/*run("Clear Results");
	run("Properties... ", "name=crop position=none stroke=none width=0 fill=none list");
	
	saveAs("Results", main_output + "/Crop-XY-" + origname + ".csv");
	results = getTitle();

	X1 =getResult("X",0); X2 =getResult("X",1); X3 =getResult("X",2); X4 =getResult("X",3);
	Y1 =getResult("Y",0); Y2 =getResult("Y",1); Y3 =getResult("Y",2); Y4 =getResult("Y",3);
	width = X2-X1; height = Y3-Y2;
	selectWindow("Crop-XY-" + origname + ".csv");
	run("Close");*/

	// crop image and filter
	selectWindow(orig);
	run("Duplicate...", "duplicate");
	run("Properties...", "channels=1 slices=1 frames=" + toString(nSlices) + " frame=[3.33 msec]");
	cropped = getTitle();
	selectWindow(orig);
	run("Close");
	selectWindow(cropped);
	run("Select None");
	//saveAs("Tiff", dir_output + origname + "-cropped");
	run("Median...", "radius=2 stack");
	setTool("line");
	makeLine(9, 3, 9, 12);
	waitForUser("Pause", "Select center of tail"); // Ask for input ROI
	run("Clear Results");
	run("Properties... ", "list");
	saveAs("Results", main_output + "/Tail-XY-" + origname + ".csv");
	LX1 =getResult("X",0); LY1 =getResult("Y",0);
	//run("Clear Results");
	selectWindow("Tail-XY-" + origname + ".csv");
	run("Close");
		
	run("Select None");
	// THRESHOLD THE FISH
	setThreshold(70, 255);
	waitForUser("Pause", "Press CTRL + SHIFT + T then adjust the threshold to select the fish");
	t0 = getNumber("1st threshold", 70);
	t1 = getNumber("2nd threshold", 255);
	//t = newArray(t0,t1,X1,Y1,width,height);
	setThreshold(t0, t1);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Light");
	win = getTitle();
	
	// REMOVE THE EDGES BY PIXEL AREA
	//minA = getNumber("Minimum area (pixel^2) of binarized object.", 0);
	minA = 200;
	runagain = 0;
	if(minA != -1){
		maxA = 0;//toString(getNumber("Maximum area (pixel^2) of binarized object. Enter 0 for Inf.", 0));
		if(maxA == 0){
			maxA = "Infinity";
			}
		run("Analyze Particles...", "size=" + toString(minA) + "-" + maxA + " show=Masks stack");
		maskwin = getTitle();
		waitForUser("Pause", "Please check the output.");
		runagain = getNumber("Would you like to run again?", 0);
		}
	
	if(runagain == 1){
		nagain = 1;
		while(nagain!=0){
			run("Close");
			selectWindow(win);
			minA = getNumber("Minimum area (pixel^2) of binarized object.", 0);
			maxA = toString(getNumber("Maximum area (pixel^2) of binarized object. Enter 0 for Inf.", 0));
			run("Analyze Particles...", "size=" + toString(minA) + "-" + maxA + " show=Masks stack");
			maskwin = getTitle();
			waitForUser("Pause", "Please check the output.");
			nagain = getNumber("Would you like to run again?", 0);
		}
	}
	selectWindow(win);
	run("Close");
	selectWindow(maskwin);
	// REMOVE THE EDGES MANUALLY
	setTool("polygon");
	imWidth = getWidth();
	makePolygon(imWidth,0,0,0,0,40,imWidth,40);
	waitForUser("Pause", "Draw ROI."); // Ask for input ROI
	//run("Clear Results");
	//run("Properties... ", "name=crop position=none stroke=none width=0 fill=none list");
	//run("Properties... ", "list");
	//results = getTitle();
	//saveAs("Results", main_output + "/Remove-XY2-" + origname + ".csv");
	saveAs("XY Coordinates", main_output + "/Remove_XY.txt");

	/*n = getValue("results.count");
	XYs = newArray(n*2);
	k = 0; // initialize the element order to convert XYS to 1D
	for (i = 0; i < n; i++) {
		XYs[k] = getResult("X", i);
		k++;
		XYs[k] = getResult("Y", i);
		k++;
	}
	//parameters = newArray(t0, t1, X1, Y1, width, height, X11, Y11, width2, height2, minA, maxA, kernel);
	parameters= newArray(8+(n*2));
	parameters[0] = t0; parameters[1] = t1; parameters[2] = X1; parameters[3] = Y1;
	parameters[4] = width; parameters[5] = height; parameters[6] = minA; parameters[7] = maxA; 
	for (i = 0; i < (n*2); i++) {
		parameters[i+8] = XYs[i];
	}
	XYs = newArray(parameters.length-8);
	for (i = 0; i < parameters.length-8; i++) {
		XYs[i] = parameters[i+8];
	}
	makePolygon(Array.slice(XYs,0,XYs.length-1));
	waitForUser("Pause", "Draw ROI."); // Ask for input ROI */
	//paras = newArray(Xs,Ys,0);
	//run("Clear Results");
	run("Subtract...", "value=255 stack");
	run("Select None");
	minA = 200;
	runagain = 0;
	if(minA != -1){
		maxA = 0;//toString(getNumber("Maximum area (pixel^2) of binarized object. Enter 0 for Inf.", 0));
		if(maxA == 0){
			maxA = "Infinity";
			}
		run("Analyze Particles...", "size=" + toString(minA) + "-" + maxA + " show=Masks stack");
		maskwin = getTitle();
		waitForUser("Pause", "Please check the output.");
		runagain = getNumber("Would you like to run again?", 0);
		}
	
	if(runagain == 1){
		nagain = 1;
		while(nagain!=0){
			run("Close");
			selectWindow(win);
			minA = getNumber("Minimum area (pixel^2) of binarized object.", 0);
			maxA = toString(getNumber("Maximum area (pixel^2) of binarized object. Enter 0 for Inf.", 0));
			run("Analyze Particles...", "size=" + toString(minA) + "-" + maxA + " show=Masks stack");
			maskwin = getTitle();
			waitForUser("Pause", "Please check the output.");
			nagain = getNumber("Would you like to run again?", 0);
		}
	}
	closing = getNumber("Would you like to run closing on morphology?", 0);
	kernel = 1;
	if(closing!=0){
		binarized = getTitle();
		run("Morphological Filters (3D)", "operation=Closing element=Ball x-radius=5 y-radius=5 z-radius=0");
		binarized_close = getTitle();
		selectWindow(binarized);
		run("Close");
		selectWindow(binarized_close);
		run("Morphological Filters (3D)", "operation=Opening element=Ball x-radius=1 y-radius=1 z-radius=0");
		binarized_open = getTitle();
		selectWindow(binarized_close);
		run("Close");
		//run("Morphological Filters (3D)", "operation=Dilation element=Ball x-radius=1 y-radius=1 z-radius=0");
		run("Analyze Particles...", "size=" + toString(minA) + "-" + maxA + " show=Masks stack");
		binarized_im = getTitle();
		selectWindow(binarized_open);
		run("Close");
		//run("Morphological Filters (3D)", "operation=Closing element=Ball x-radius=" + toString(kernel) + " y-radius=" + toString(kernel) + " z-radius=0");
		}
	
	// SKELETONIZE THE IMAGE
	outfolder = replace(file, ".avi", "");
	output = input + "/tail/" + outfolder;
	if(File.exists(output) != 1){
		File.makeDirectory(output);
	}
	run("Select None");
	saveAs("Tiff", main_output + "\\BIN_" + origname + ".tif");
	binarized_im = getTitle();
	for(s = 1; s <= nSlices; s++){
		selectWindow(binarized_im);
		setSlice(s); // start from first frame
		run("Duplicate...", "use"); // isolate the frame
		run("Skeletonize (2D/3D)");
		current_slice = getTitle();
		curr = replace(current_slice, ".avi", "");
		saveAs("Tiff", output + "/" + toString(s) + ".tif");
		run("Close");
		}
	
	
	run("Image Sequence...", "open=["+output+"/1.tif] sort");
	skel_output = main_output + "/skel/";
	if(File.exists(skel_output) != 1){
		File.makeDirectory(skel_output);
	}
	saveAs("Tiff", skel_output + "Skel_" + origname + ".tif");
	run("Close All");
	parameters = newArray(t0,t1,minA,maxA);
	return parameters;
}


function others_trackTail(input, file, param){
	main_output = input + "/tail";
	if(File.exists(main_output) != 1){
		File.makeDirectory(main_output);
	}
	// open file
	open(input + file);
	orig = getTitle();
	origname = replace(orig,".avi","");
	run("XY Coordinates... ", "open=["+ main_output+ "/Crop_XY.txt]");
	/*X1 = param[2]; Y1 = param[3];
	width = param[4]; height = param[5];
	run("Specify...", "width=" + width + " height=" + height + " x=" + X1 + " y=" + Y1 + " slice=1");*/
	// crop image and filter
	selectWindow(orig);
	run("Duplicate...", "duplicate");
	run("Properties...", "channels=1 slices=1 frames=" + toString(nSlices) + " frame=[3.33 msec]");
	cropped = getTitle();
	selectWindow(orig);
	run("Close");
	selectWindow(cropped);
	run("Select None");
	//saveAs("Tiff", dir_output + origname + "-cropped");
	run("Median...", "radius=2 stack");
	
	// THRESHOLD THE FISH
	t0 = param[0];
	t1 = param[1];
	//t = newArray(t0,t1,X1,Y1,width,height);
	setThreshold(t0, t1);
	waitForUser("Pause", "Press CTRL + SHIFT + T then adjust the threshold to select the fish");
	t0 = getNumber("1st threshold", param[0]);
	t1 = getNumber("2nd threshold", param[1]);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Light");
	win = getTitle();
	
	// REMOVE THE EDGES BY PIXEL AREA
	minA = param[2];
	if(minA != -1){
		maxA = param[3];
		if(maxA == 0){
			maxA = "Infinity";
			}
		run("Analyze Particles...", "size=" + toString(minA) + "-" + maxA + " show=Masks stack");
		maskwin = getTitle();
		waitForUser("Pause", "Please check the output.");
		runagain = getNumber("Would you like to run again?", 0);
		}

	if(runagain == 1){
		nagain = 1;
		while(nagain!=0){
			run("Close");
			selectWindow(win);
			minA = getNumber("Minimum area (pixel^2) of binarized object.", 0);
			maxA = toString(getNumber("Maximum area (pixel^2) of binarized object. Enter 0 for Inf.", 0));
			run("Analyze Particles...", "size=" + toString(minA) + "-" + maxA + " show=Masks stack");
			maskwin = getTitle();
			waitForUser("Pause", "Please check the output.");
			nagain = getNumber("Would you like to run again?", 0);
		}
	}
	selectWindow(win);
	run("Close");
	// REMOVE THE EDGES MANUALLY
	/*
	setTool("rectangle");
	XYs = newArray(param.length-8);
	for (i = 0; i < param.length-8; i++) {
		XYs[i] = param[i+8];
	}
	//parameters= newArray(8+(XYs.length));
	//parameters[0] = t0; parameters[1] = t1; parameters[2] = X1; parameters[3] = Y1;
	//parameters[4] = width; parameters[5] = height; parameters[6] = minA; parameters[7] = maxA; 
	//for (i = 0; i < XYs.length; i++) {
	//	parameters[i+8] = XYs[i];
	//}
	//X11 = param[6]; Y11 = param[7];
	//width2 = param[8]; height2 = param[9];
	//run("Specify...", "width=" + width2 + " height=" + height2 + " x=" + X11 + " y=" + Y11 + " slice=1");
	makePolygon(Array.slice(XYs,0,XYs.length);
	//waitForUser("Pause", "Please check the ROI.");*/
	selectWindow(maskwin);
	run("XY Coordinates... ", "open=["+ main_output+ "/Remove_XY.txt]");
	waitForUser("Pause", "Draw ROI."); // Ask for input ROI
	run("Subtract...", "value=255 stack");
	run("Select None");
	win = getTitle();
	minA = param[2];
	if(minA != -1){
		maxA = param[3];
		if(maxA == 0){
			maxA = "Infinity";
			}
		run("Analyze Particles...", "size=" + toString(minA) + "-" + maxA + " show=Masks stack");
		maskwin = getTitle();
		waitForUser("Pause", "Please check the output.");
		runagain = getNumber("Would you like to run again?", 0);
		}

	if(runagain == 1){
		nagain = 1;
		while(nagain!=0){
			run("Close");
			selectWindow(win);
			minA = getNumber("Minimum area (pixel^2) of binarized object.", 0);
			maxA = toString(getNumber("Maximum area (pixel^2) of binarized object. Enter 0 for Inf.", 0));
			run("Analyze Particles...", "size=" + toString(minA) + "-" + maxA + " show=Masks stack");
			maskwin = getTitle();
			waitForUser("Pause", "Please check the output.");
			nagain = getNumber("Would you like to run again?", 0);
		}
	}
	closing = getNumber("Would you like to run closing on morphology?", 0);
	kernel = 1;
	if(closing!=0){
		binarized = getTitle();
		run("Morphological Filters (3D)", "operation=Closing element=Ball x-radius=5 y-radius=5 z-radius=0");
		binarized_close = getTitle();
		selectWindow(binarized);
		run("Close");
		selectWindow(binarized_close);
		run("Morphological Filters (3D)", "operation=Opening element=Ball x-radius=1 y-radius=1 z-radius=0");
		binarized_open = getTitle();
		selectWindow(binarized_close);
		run("Close");
		//run("Morphological Filters (3D)", "operation=Dilation element=Ball x-radius=1 y-radius=1 z-radius=0");
		run("Analyze Particles...", "size=" + toString(minA) + "-" + maxA + " show=Masks stack");
		binarized_im = getTitle();
		selectWindow(binarized_open);
		run("Close");
		//run("Morphological Filters (3D)", "operation=Closing element=Ball x-radius=" + toString(kernel) + " y-radius=" + toString(kernel) + " z-radius=0");
		}

	// SKELETONIZE THE IMAGE
	outfolder = replace(file, ".avi", "");
	output = input + "/tail/" + outfolder;
	if(File.exists(output) != 1){
		File.makeDirectory(output);
	}
	run("Select None");
	saveAs("Tiff", main_output + "\\BIN_" + origname + ".tif");
	binarized_im = getTitle();
	for(s = 1; s <= nSlices; s++){
		selectWindow(binarized_im);
		setSlice(s); // start from first frame
		run("Duplicate...", "use"); // isolate the frame
		run("Skeletonize (2D/3D)");
		current_slice = getTitle();
		curr = replace(current_slice, ".avi", "");
		saveAs("Tiff", output + "/" + toString(s) + ".tif");
		run("Close");
		}
	
	run("Image Sequence...", "open=["+output+"/1.tif] sort");
	skel_output = main_output + "/skel/";
	if(File.exists(skel_output) != 1){
		File.makeDirectory(skel_output);
	}
	saveAs("Tiff", skel_output + "Skel_" + origname + ".tif");
	run("Close All");
	param = newArray(t0,t1,minA,maxA);
	return param;
}


