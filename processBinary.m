function out = processBinary(I)
% Processes a nucleus image from a GFP MIP cropped. 
% First, ensure there's only one region using bwconncomp.
% If not, only take the biggest blob.
% Next, measure area and eccentricity

% Binarize the image.
iBin = imbinarize(mat2gray(I));

% Keep only the biggest object, if there are multiple. The biggest one will
% always be the nucleus.
iBin = keepMaxObj(iBin);
[labeledImage, n] = bwlabel(iBin);

% If there is more than one region in the binarized image, don't include it
% in the analysis. Otherwise calculate the area and the eccentricity using
% MATLAB's built-in function "regionprops"
if n > 1
   out = 0;
else
    ecc = regionprops(iBin, 'Eccentricity');
    ecc = ecc.Eccentricity;
    area = numel(iBin(iBin==1));
    disp(area);
    out = [area, ecc];
end
end