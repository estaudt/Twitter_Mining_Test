%% 
%function [centers, assignments] = cluster_base_descs( lower_limit, upper_limit, numClusters )
% perform clustering on base-level descriptors and save the resulting
% cluster centers and assignments. Loads descriptors from objects into one
% large matrix in order to cluster the entire group.
numClusters = 200;

objectDir = '/Users/elliotstaudt/Documents/MIRFLICKR-25000/objects/';
object_descriptors = [];

% ojbect MAT files are listed as numbers and we only have 00000-24999, but
% loading them all would deplete memory so we must use a psuedo-random
% sample from the training portion of the dataset
tic;
for count = 0:4999
    object_folder = fullfile( objectDir, sprintf('%05d',count) );
    local_object_file_names = dir( fullfile(object_folder,'object_*.mat') );
    if numel(local_object_file_names) > 0
        for count2 = 1:numel(local_object_file_names)
            object_mat = load( fullfile( object_folder,local_object_file_names(count2).name),'d' );
            object_descriptors = [object_descriptors single(object_mat.d)];
        end
    end
end
toc;

% commence clustering on descriptors
disp('Commence Clustering');
disp(['Clustering with ' num2str(numClusters) ' clusters'])
tic;
[centers, assignments] = vl_kmeans(object_descriptors, numClusters, 'NumRepetitions', 20, 'MaxNumComparisons', numClusters) ;
% save clustering results for later
save( ['/Users/elliotstaudt/Documents/MIRFLICKR-25000/Clusters/first_5k_' num2str(numClusters) '_clusters.mat'], 'centers','assignments' )
toc;
disp('fin');

%%
% Build kdforrest for fast indexing and then perform indexing on rest of
% the base level descriptor dataset
% build kdforrest for fast indexing
clusterDir = '/Users/elliotstaudt/Documents/MIRFLICKR-25000/Clusters';
numClusters = [100,200,500,1000];
cluster_ind = 2;

clustering_product = load( fullfile( clusterDir, ['first_5k_' num2str(numClusters(cluster_ind)) '_clusters.mat']), 'centers','assignments' );
tic;
kdforrest = vl_kdtreebuild(clustering_product.centers, 'NumTrees', 4) ;
toc;

% index descriptors for each of the objects,
% load the descriptors from each object
%objectDir = '/Users/elliotstaudt/Documents/MIRFLICKR-25000/objects/';
objectDir = '/Users/elliotstaudt/Documents/MIRFLICKR/objects/2/';
object_descriptors = [];

tic;
for count = 25000:25999
    disp(count)
    object_folder = fullfile( objectDir, sprintf('%05d',count) );
    local_object_file_names = dir( fullfile(object_folder,'object*.mat') );
    if numel(local_object_file_names) > 0
        for count2 = 1:numel(local_object_file_names)
            BOW  = zeros(numClusters(cluster_ind),1);
            object_mat = load( fullfile( object_folder,local_object_file_names(count2).name),'d' );
            query = single(object_mat.d);
            [index, distance] = vl_kdtreequery(kdforrest, clustering_product.centers, query);
            for count3 = 1:numel(index)
                BOW(index(count3)) = BOW(index(count3))+1;
            end
%            BOW = BOW/sum(BOW);
            save( fullfile( object_folder, ['BoW' num2str(numClusters(cluster_ind)) '_obj_' sprintf('%02d',count2) '.mat'] ), 'BOW' );           
        end
    end
end
toc;

%%
% commence clustering on BoWs
clc;
clear all
close all
% commence clustering
disp('Commence Clustering');
numClusters = [100,200,500,1000];
cluster_ind = 2;

% Gather the BoW descriptors for each object
objectDir = '/Users/elliotstaudt/Documents/MIRFLICKR-25000/objects/';
BOW_descriptors = [];

tic;
for count = 0:24999
    object_folder = fullfile( objectDir, sprintf('%05d',count) );
    local_object_file_names = dir( fullfile(object_folder,['BoW' num2str(numClusters(cluster_ind)) '*.mat']) );
    if numel(local_object_file_names) > 0
        for count2 = 1:numel(local_object_file_names)
            BOW = load(fullfile(object_folder,local_object_file_names(count2).name),'BOW');
            BOW_descriptors = [BOW_descriptors BOW.BOW];
        end
    end
end
toc;

disp(['Clustering with ' num2str(numClusters(cluster_ind)) ' clusters'])

tic;
[centers, assignments] = vl_kmeans(BOW_descriptors, numClusters(cluster_ind), 'verbose', 'NumRepetitions', 20, 'MaxNumComparisons', numClusters(cluster_ind)) ;
% save clustering results for later
save( ['/Users/elliotstaudt/Documents/MIRFLICKR-25000/Clusters/BOW_' num2str(numClusters(cluster_ind)) '_clusters.mat'], 'centers','assignments' )
toc;

disp('fin');

%% Create Assignments for Individual BOW object representations


bow_cluster_file = '/Users/elliotstaudt/Documents/MIRFLICKR-25000/Clusters/BOW_200_clusters.mat';
clusterDir = '/Users/elliotstaudt/Documents/MIRFLICKR-25000/Clusters';
numClusters = [100,200,500,1000];
cluster_ind = 2;

clustering_product = load( bow_cluster_file, 'centers','assignments' );
tic;
kdforrest = vl_kdtreebuild(clustering_product.centers, 'NumTrees', 4) ;
toc;

% index BOW descriptor for each of the objects,
% load the descriptor from each object
objectDir = '/Users/elliotstaudt/Documents/MIRFLICKR-25000/objects/';
%objectDir = '/Users/elliotstaudt/Documents/MIRFLICKR/objects/2/';
object_descriptors = [];

tic;
%for count = 25000:25999
for count = 0:24999
    disp(count)
    object_folder = fullfile( objectDir, sprintf('%05d',count) );
    local_object_file_names = dir( fullfile(object_folder,'BoW200_*.mat') );
    if numel(local_object_file_names) > 0
        for count2 = 1:numel(local_object_file_names)
            object_mat = load( fullfile( object_folder,local_object_file_names(count2).name),'BOW' );
            query = single(object_mat.BOW);
            [index, distance] = vl_kdtreequery(kdforrest, clustering_product.centers, object_mat.BOW);
            save( fullfile( object_folder, ['objClass_obj_' sprintf('%02d',count2) '.mat'] ), 'index' );           
        end
    end
end
toc;

%%
clc
clear all
close all

step = 1000;

% MIRFLICKR-25000
%imageDir = '/Users/elliotstaudt/Documents/MIRFLICKR-25000/images/';
%objectDir = '/Users/elliotstaudt/Documents/MIRFLICKR-25000/objects/';

% MIRFLICKR
imageDir = '/Users/elliotstaudt/Documents/MIRFLICKR/images/2/';
objectDir = '/Users/elliotstaudt/Documents/MIRFLICKR/objects/2/';

%{
for count = 21000:1000:24000
    process_mirflickr25k( imageDir, objectDir, count, step );
end
%}


process_mirflickr25k( imageDir, objectDir, 25605, 395 );


%%
tally = zeros(200,1);

for count = 1:numel(assignments)
    tally(assignments(count)) = tally(assignments(count)) + 1;
end

%%
cluster_folder_path = '/Users/elliotstaudt/Documents/MIRFLICKR-25000/Clusters/200';
for num = 0:199
    mkdir(fullfile(cluster_folder_path,num2str(num)));
end
