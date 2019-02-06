README
================

This software is preliminary or provisional and is subject to revision. It is being provided to meet the need for timely best science. The software has not received final approval by the U.S. Geological Survey (USGS). No warranty, expressed or implied, is made by the USGS or the U.S. Government as to the functionality of the software and related material nor shall the fact of release constitute any such warranty. The software is provided on the condition that neither the USGS nor the U.S. Government shall be held liable for any damages resulting from the authorized or unauthorized use of the software.

What this app does
------------------

This app interpolates flow and gage height values corresponding to QW sample times. If available, it will also give the discharge and gage height associated with a sample if they were entered in QWDATA.

Running the app remotely
------------------------

You will need to have the [dataRetrieval](https://github.com/USGS-R/dataRetrieval) and [shiny](https://github.com/rstudio/shiny) packages installed. This could be done by running the following commands in an R Console (or RStudio):

``` r
install.packages("dataRetrieval")
install.packages("shiny")
```

Once you have the packages installed, you can start the app with the following commands:

``` r
library(dataRetrieval)
library(shiny)
runGitHub("PatrickEslick/SampleQ", launch.browser=TRUE)
```

Using the app
-------------

If the app launched in the browser, its ready to use.

1.  Type the location number for your site
2.  Select the date range you are interested in
3.  Adjust the slider to the maximum gap (in hours) between which you would like to interpolate. For example, if the slider is set at 4, but there is a gap in discharge of 5 hours around a sample time, no value will be given.
4.  Select the method used to merge the sample times with the discharge and gage height data. By default, the app will interpolate between the two closest points. The other option is to simply use the closest time series point to each sample time.
5.  Click "Get data", a message will appear in the lower right corner indicating that the app is working. If something doesn't work, you will see an error message there. If everything works correctly, you will see a preview of the data.
6.  To download the data to a csv file, click "Download"
a
