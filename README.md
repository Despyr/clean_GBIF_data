# clean_GBIF_data
Check if the coordinates of the GBIF occurrences fall within the polygon associated with the species mentioned in the WorldChekList Distribution

Three different databases are used: 
   - (1) The level 3 division of Brummitt, 2001
   - (2) A GBIF occurrence table (ANID, latitude, longitude)
   - (3) The WorldCheckList species distribution table (ANID, latitude, longitude, polygon ID)


We load level 3 division of Brummitt (1) via the GIS packages associated with R to the projection we want.
From this database (1), we extract the coordinates and the ID defining each of the division 3 polygons and store them in a table. (named shape_f in my data).

We will merge table (2) and table (3) on the basis of similar ANIDs to match each ANID in table (2) with the ID of the associated polygon in table (3).
We thus obtain a new file (4) with all the information of the table (2) and an additional column showing the ID of the polygon associated with each ANID. 

The loop will, for each line, keep in the shape_i object the ID of the polygon of the line. 
Then the shape_poly object will go to match the set of coordinates (lat,long) linked to this polygon ID in the shape_f file.
Finally, we create a new column in our input file where we print the result of the point.in.polygon() function which, 
by providing the coordinates of each line one by one (so each occurrence of our table (4)) and the coordinates
defining the polygon ID associated with each line (contained in the shape_poly object), tells us if the point resulting from the
coordinates of the occurrence falls in the polygon associated with it. 

