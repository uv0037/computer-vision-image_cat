% Implementated according to the starter code prepared by James Hays, Brown
% University 
% Michal Mackiewicz, UEA

function image_feats = get_bags_of_sifts(image_paths, vocab_size)
% image_paths is an N x 1 cell array of strings where each string is an
% image path on the file system.

% This function assumes that 'vocab.mat' exists and contains an N x 128
% matrix 'vocab' where each row is a kmeans centroid or a visual word. This
% matrix is saved to disk rather than passed in a parameter to avoid
% recomputing the vocabulary every time at significant expense.

% image_feats is an N x d matrix, where d is the dimensionality of the
% feature representation. In this case, d will equal the number of clusters
% or equivalently the number of entries in each image's histogram.

% You will want to construct SIFT features here in the same way you
% did in build_vocabulary.m (except for possibly changing the sampling
% rate) and then assign each local feature to its nearest cluster center
% and build a histogram indicating how many times each cluster was used.
% Don't forget to normalize the histogram, or else a larger image with more
% SIFT features will look very different from a smaller version of the same
% image.

%{
Useful functions:
[locations, SIFT_features] = vl_dsift(img) 
 http://www.vlfeat.org/matlab/vl_dsift.html
 locations is a 2 x n list list of locations, which can be used for extra
  credit if you are constructing a "spatial pyramid".
 SIFT_features is a 128 x N matrix of SIFT features
  note: there are step, bin size, and smoothing parameters you can
  manipulate for vl_dsift(). We recommend debugging with the 'fast'
  parameter. This approximate version of SIFT is about 20 times faster to
  compute. Also, be sure not to use the default value of step size. It will
  be very slow and you'll see relatively little performance gain from
  extremely dense sampling. You are welcome to use your own SIFT feature
  code! It will probably be slower, though.

D = vl_alldist2(X,Y) 
   http://www.vlfeat.org/matlab/vl_alldist2.html
    returns the pairwise distance matrix D of the columns of X and Y. 
    D(i,j) = sum (X(:,i) - Y(:,j)).^2
    Note that vl_feat represents points as columns vs this code (and Matlab
    in general) represents points as rows. So you probably want to use the
    transpose operator '  You can use this to figure out the closest
    cluster center for every SIFT feature. You could easily code this
    yourself, but vl_alldist2 tends to be much faster.
%}

% load('vocab.mat')
load(['vocab_size_gray', num2str(vocab_size),'.mat']);
vocab_size = size(vocab, 2);

step = 4;
bin_size = 4;
image_feats = [];
forest = vl_kdtreebuild(vocab');

% for i = 1:length(image_paths)
%     img = single( imread(image_paths{i}) );
%     if size(img, 3) > 1
%         img =rgb2gray(img);
%     end
% 
%     % points = detectSIFTFeatures(img)
%     % imshow(img);
%     % hold on;
%     % plot(points.selectStrongest(10))
% 
%     % [locations, SIFT_features] = vl_sift(img);
%     [locations, SIFT_features] = vl_dsift(img, 'fast', 'step', step, 'size', bin_size);
% 
% 
%     [index , dist] = vl_kdtreequery(forest , vocab' , double(SIFT_features));
% 
%     feature_hist = hist(double(index), vocab_size);
% 
%     % used l2 normalisation
%     % l2_norm = sqrt(sum(feature_hist.^2));
%     % feature_hist = feature_hist ./ l2_norm;
% 
% 
% 
%     %feature_hist = feature_hist ./ sum(feature_hist);
%      feature_hist = feature_hist ./ norm(feature_hist);
% 
%     image_feats(i, :) = feature_hist;
% end

for i = 1:length(image_paths)
    img = single(imread(image_paths{i}));
    for channel = 1:size(img, 3)
            img_channel = img(:, :, channel);
            [locations, SIFT_features] = vl_dsift(img_channel, 'fast', 'step', step, 'size', bin_size);
            %[locations, SIFT_features] = vl_sift(img_channel);

            [index , dist] = vl_kdtreequery(forest , vocab' , double(SIFT_features));

            feature_hist = hist(double(index), vocab_size);

            % used l2 normalisation
            % l2_norm = sqrt(sum(feature_hist.^2));
            % feature_hist = feature_hist ./ l2_norm;



            feature_hist = feature_hist ./ sum(feature_hist);
            %feature_hist = feature_hist ./ norm(feature_hist);

            image_feats(i, :) = feature_hist;

    end  

end

