% Michal Mackiewicz, UEA 
% This code has been adapted from the code 
% prepared by James Hays, Brown University

%% Step 0: Set up parameters, vlfeat, category list, and image paths.

%For this project, you will need to report performance for three
%combinations of features / classifiers. It is suggested you code them in
%this order, as well:
% 1) Tiny image features and nearest neighbor classifier
% 2) Bag of sift features and nearest neighbor classifier
% 3) Bag of sift features and linear SVM classifier
%The starter code is initialized to 'placeholder' just so that the starter

%code does not crash when run unmodified and you can get a preview of how
%results are presented.
% Increase maximum array size preference (not recommended unless necessary)

% FEATURE = 'tiny image';
% FEATURE = 'colour histogram';
% FEATURE = 'bag of sift';
FEATURE = 'spatial pyramids';

 % CLASSIFIER = 'nearest neighbor';
  CLASSIFIER = 'support vector machine';

% set up paths to VLFeat functions. 
% See http://www.vlfeat.org/matlab/matlab.html for VLFeat Matlab documentation
% This should work on 32 and 64 bit versions of Windows, MacOS, and Linux
run('vlfeat-0.9.21/toolbox/vl_setup.m')


data_path = '../data/';

%This is the list of categories / directories to use. The categories are
%somewhat sorted by similarity so that the confusion matrix looks more
%structured (indoor and then urban and then rural).
categories = {'Kitchen', 'Store', 'Bedroom', 'LivingRoom', 'House', ...
       'Industrial', 'Stadium', 'Underwater', 'TallBuilding', 'Street', ...
       'Highway', 'Field', 'Coast', 'Mountain', 'Forest'};
   
%This list of shortened category names is used later for visualization.
abbr_categories = {'Kit', 'Sto', 'Bed', 'Liv', 'Hou', 'Ind', 'Sta', ...
    'Und', 'Bld', 'Str', 'HW', 'Fld', 'Cst', 'Mnt', 'For'};
    
%number of training examples per category to use. Max is 100. For
%simplicity, we assume this is the number of test cases per category, as
%well.
num_train_per_cat = 100; 

%This function returns cell arrays containing the file path for each train
%and test image, as well as cell arrays with the label of each train and
%test image. By default all four of these arrays will be 1500x1 where each
%entry is a char array (or string).
fprintf('Getting paths and labels for all train and test data\n')
[train_image_paths, test_image_paths, train_labels, test_labels] = ...
    get_image_paths(data_path, categories, num_train_per_cat);
%   train_image_paths  1500x1   cell      
%   test_image_paths   1500x1   cell           
%   train_labels       1500x1   cell         
%   test_labels        1500x1   cell          

%% Step 1: Represent each image with the appropriate feature
% Each function to construct features should return an N x d matrix, where
% N is the number of paths passed to the function and d is the 
% dimensionality of each image representation. See the starter code for
% each function for more details.

fprintf('Using %s representation for images\n', FEATURE)

switch lower(FEATURE)    
    case 'tiny image'
        %You need to reimplement get_tiny_images. Allow function to take
        %parameters e.g. feature size.
        
        % image_paths is an N x 1 cell array of strings where each string is an
        %  image path on the file system.
        % image_feats is an N x d matrix of resized and then vectorized tiny
        %  images. E.g. if the images are resized to 16x16, d would equal 256.
        
        % To build a tiny image feature, simply resize the original image to a very
        % small square resolution, e.g. 16x16. You can either resize the images to
        % square while ignoring their aspect ratio or you can crop the center
        % square portion out of each image. Making the tiny images zero mean and
        % unit length (normalizing them) will increase performance modestly.
        
        train_image_feats = get_tiny_images(train_image_paths);
        test_image_feats  = get_tiny_images(test_image_paths);
    case 'colour histogram'
        %You should allow get_colour_histograms to take parameters e.g.
        %quantisation, colour space etc.
        train_image_feats = get_colour_histograms(train_image_paths);
        test_image_feats  = get_colour_histograms(test_image_paths);

    case 'bag of sift'
        % YOU CODE build_vocabulary.m
        vocab_size = 240; %Larger values will work better (to a point) but be slower to compute
        if ~exist(['vocab/vocab_size_gray' ...
                '', num2str(vocab_size),'.mat'], 'file')
            fprintf('No existing visual word vocabulary found. Computing one from training images\n')
            vocab = build_vocabulary(train_image_paths, vocab_size);
            save(['vocab/vocab_size_gray', num2str(vocab_size),'.mat'], 'vocab')
        end
        
        % YOU CODE get_bags_of_sifts.m
        if ~exist(['vocab/train_image_feats_size_color', num2str(vocab_size),'.mat'], 'file')
            train_image_feats = get_bags_of_sifts(train_image_paths, vocab_size);
			save(['vocab/train_image_feats_size_color', num2str(vocab_size), '.mat'], 'train_image_feats');
        else
            load(['vocab/train_image_feats_size_color', num2str(vocab_size),'.mat']);
        end
        
        if ~exist(['vocab/test_image_feats_size_color', num2str(vocab_size), '.mat'])
            test_image_feats  = get_bags_of_sifts(test_image_paths, vocab_size);
			save(['vocab/test_image_feats_size_color', num2str(vocab_size), '.mat'], 'test_image_feats');
        else
            load(['vocab/test_image_feats_size_color', num2str(vocab_size), '.mat']);
        end
      case 'spatial pyramids'
          % YOU CODE spatial pyramids method
          levels = 2;
          vocab_size = 360;
          [train_image_feats, test_image_feats] = get_spatial_pyramids(train_image_paths, test_image_paths,vocab_size, levels);
end
%% Step 2: Classify each test image by training and using the appropriate classifier
% Each function to classify test features will return an N x 1 cell array,
% where N is the number of test cases and each entry is a string indicating
% the predicted category for each test image. Each entry in
% 'predicted_categories' must be one of the 15 strings in 'categories',
% 'train_labels', and 'test_labels'. See the starter code for each function
% for more details.

fprintf('Using %s classifier to predict test set categories\n', CLASSIFIER)

switch lower(CLASSIFIER)    
    case 'nearest neighbor'
    %Here, you need to reimplement nearest_neighbor_classify. My P-code
    %implementation has k=1 set. You need to allow for varying this
    %parameter.
        
    %This function will predict the category for every test image by finding
    %the training image with most similar features. Instead of 1 nearest
    %neighbor, you can vote based on k nearest neighbors which will increase
    %performance (although you need to pick a reasonable value for k).
    
    % image_feats is an N x d matrix, where d is the dimensionality of the
    %  feature representation.
    % train_labels is an N x 1 cell array, where each entry is a string
    %  indicating the ground truth category for each training image.
    % test_image_feats is an M x d matrix, where d is the dimensionality of the
    %  feature representation. You can assume M = N unless you've modified the
    %  starter code.
    % predicted_categories is an M x 1 cell array, where each entry is a string
    %  indicating the predicted category for each test image.
    % Useful functions: pdist2 (Matlab) and vl_alldist2 (from vlFeat toolbox)
       k=13;
       distance_measure = 'manhattan';
       predicted_categories = nearest_neighbor_classify(train_image_feats, train_labels, test_image_feats,k, distance_measure);

    case 'support vector machine'

        predicted_categories = svm_classify(train_image_feats, train_labels, test_image_feats, test_labels);
end

%% Step 3: Build a confusion matrix and score the recognition system
% You do not need to code anything in this section. 

% This function will recreate results_webpage/index.html and various image
% thumbnails each time it is called. View the webpage to help interpret
% your classifier performance. Where is it making mistakes? Are the
% confusions reasonable?
create_results_webpage( train_image_paths, ...
                        test_image_paths, ...
                        train_labels, ...
                        test_labels, ...
                        categories, ...
                        abbr_categories, ...
                        predicted_categories)