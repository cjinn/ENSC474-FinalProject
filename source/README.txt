INTRODUCTION

This text file is used purely as a development notebook to log down any changes that have been made. This is to ensure that progress during ongoing development is recorded down so that it is not lost to the wind, and that the developer is not lost to the wind during debugging/development.

This only covers the high-level thought process during development. Any changes to the code is not recorded down for simplicity sake. 

DEBUGGING

When debugging, set parameter DEBUG in receptorCounter(~,~,debug) to the following debug commands:
	- 'all': Spits out everything
	- 'segmentation': Analyses only segmentation
    -

During production, set parameter DEBUG to 'none'.

FORMAT

Each changelog is marked down in the following notation:
- vX.YY.ZZZ (DATE)
    - v: version
    - X: Major release version.
        - 0: Ongoing development. Not production ready
        - 1: Production ready
        - 2: Major upgrade to version 1 (pipe dream)
    - YY: Minor release version
        - Increments with every stable release.
        - If import
    - ZZZ: Test change
        - Up to the discerenary 
        - 

CHANGELOG:
v0.01.001
 - Created this text file to log down changes
 - Created receptorCounter as the main function
 - Created main.m as the "main" function to run it
 - Created supporting functions
 - Created PowerPoint presentation
 - Put files into Git for code changes

v0.01.002
 - Fixed bug related to saving debugging files
 - Fixed bug related to saving initial intensity segmentation
 - Filters out the first two clusters
 - Saved debug files in different folders based on version


v0.01.003
 - Filters out the first three clusters

v0.01.004
 - Applies mask (odd-numbered) to the filtered image
 - Fixed bug where debugging folder is not created

v0.01.005
 - Turns masked image into map image using colour to indicate density
 - Implemented writeImage into receptorCounter.m
 - Exports map to folder 'Results'

GOAL:
v0.02.001
 - Create validation data set on control group, "diseased" images, etc
 - Run tests with validation data set and note results

v0.03.001
 - Documented all processes and decisions

v1.00.000 (Targetted)
 - Completed documentation
 - Ready for production
