cd 0404WoodProcessedBalancedInputData;
#for ii in $(ls);
#do 
#    cd $ii; 
#    rm *.png;
#    cd ..;
#done

newImagesLinkPath=D:\MatlabWorkspace\woodSamplesClassification\images/0404CropProcessed/;
for ii in $(ls); 
do 
    cd $ii; 
    for jj in  $(seq -f "%03g" 1 30);
    do 
        targetName=$(ls -l $jj.png | cut -d'>' -f2 | cut -d'/' -f9,10); 
        rm -i $jj.png;
        ln  $newImagesLinkPath$targetName $jj.png; 
    done; 
    cd ..; 
done

