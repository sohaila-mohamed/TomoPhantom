function [reconstructon] = rec2Dastra(sino, angles, detsize, N, device)


proj_geom = astra_create_proj_geom('parallel', 1, detsize, angles);
vol_geom = astra_create_vol_geom(N,N);

cfg = astra_struct('FBP_CUDA');
cfg.FilterType = 'Ram-Lak';


if (strcmp(device, 'cpu') == 1)
    proj_id = astra_create_projector('strip', proj_geom, vol_geom);
    cfg.ProjectorId = proj_id;
elseif (strcmp(device, 'gpu') == 1)    
    
else
    error('Device is not selected, please choose between cpu and gpu')    
end
    
rec_id = astra_mex_data2d('create', '-vol', vol_geom);
sinogram_id = astra_mex_data2d('create', '-sino', proj_geom, sino);
cfg.ReconstructionDataId = rec_id;
cfg.ProjectionDataId = sinogram_id;

alg_id = astra_mex_algorithm('create', cfg);
astra_mex_algorithm('run', alg_id);
 
% Get the result
reconstructon = astra_mex_data2d('get', rec_id);

% % Clean up. Note that GPU memory is tied up in the algorithm object,
% % and main RAM in the data objects.
astra_mex_algorithm('delete', alg_id);
astra_mex_data2d('delete', sinogram_id);
astra_mex_data2d('delete', rec_id);
if (strcmp(device, 'cpu') == 1)
astra_mex_data2d('delete', proj_id);
end