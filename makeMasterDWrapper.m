% Master D wrapper
plotMe = 0;
saveMe = 1;


%% main data
masterD_pos_bnd0 = getDfromGridAveAsymp( './gridAveMSDdata/paperData_t600/bD0/bePos/', 'aveGrid_*',plotMe,0 );
if saveMe
  save('masterD_pos_bnd0','masterD_pos_bnd0');
end

masterD_neg_bnd0 = getDfromGridAveAsymp( './gridAveMSDdata/paperData_t600/bD0/beNeg/', 'aveGrid_*',plotMe,0 );
if saveMe
  save('masterD_neg_bnd0','masterD_neg_bnd0');
end

masterD_pos_bnd1 = getDfromGridAveAsymp( './gridAveMSDdata/paperData_t600/bD1/', 'aveGrid_*',plotMe,0 );
if saveMe
  save('masterD_pos_bnd1','masterD_pos_bnd1');
end

masterD_neg_bnd1 = getDfromGridAveAsymp( './gridAveMSDdata/paperData_t600/bD1/', 'aveGrid_*',plotMe,0 );
masterD_neg_bnd1(:,2) = -masterD_neg_bnd1(:,2);
masterD_neg_bnd1(:,3) = 1 - masterD_neg_bnd1(:,3);
if saveMe
  save('masterD_neg_bnd1','masterD_neg_bnd1');
end


%% bnd diff
masterD_bnddiff = getDfromGridAveAsymp( './gridAveMSDdata/bndDiffEffects/', 'aveGrid_*',plotMe,0 );
if saveMe
  save('masterD_bnddiff','masterD_bnddiff');
end

%% size
% edge 0
% edge 1
masterD_size_oe1_bnd0 = getDfromGridAveAsymp( './gridAveMSDdata/sizeEffects/edge1/', 'aveGrid_msd_unD1_bD0.00*',plotMe,0 );
if 1
  save('masterD_size_oe1_bnd0','masterD_size_oe1_bnd0');
end

% edge 0
masterD_size_oe1_bnd1 = getDfromGridAveAsymp( './gridAveMSDdata/sizeEffects/edge0/oe1/', 'aveGrid_msd_unD1_bD1.00*',plotMe,0 );
if saveMe
  save('masterD_size_oe1_bnd1','masterD_size_oe1_bnd1');
end

%% 3d
masterD_3d_bnd1 = getDfromGridAveAsymp( './gridAveMSDdata/3dEffects/bD1/', 'aveGrid_msd_unD1_bD1.00*', plotMe, 0 );
if saveMe
  save('masterD_3d_bnd1','masterD_3d_bnd1');
end
masterD_3d_bnd0 = getDfromGridAveAsymp( './gridAveMSDdata/3dEffects/bD0/', 'aveGrid_msd_unD1_bD0.00*', plotMe, 0 );
if saveMe
  save('masterD_3d_bnd0','masterD_3d_bnd0');
end

% lPerc
%% bnd 0

plotMe = 1;
masterD_l1_oe1_bnd0 = getDfromGridAveAsymp( './gridAveMSDdata/lPerc/edge1/bD0/l1/', 'aveGrid_*',plotMe,0 );
if saveMe
  save('masterD_l1_oe1_bnd0','masterD_l1_oe1_bnd0');
end
%%
masterD_l3_oe1_bnd0 = getDfromGridAveAsymp( './gridAveMSDdata/lPerc/edge1/bD0/l3/', 'aveGrid_*',plotMe,0 );
if saveMe
  save('masterD_l3_oe1_bnd0','masterD_l3_oe1_bnd0');
end
masterD_l5_oe1_bnd0 = getDfromGridAveAsymp( './gridAveMSDdata/lPerc/edge1/bD0/l5/', 'aveGrid_*',plotMe,0 );
if saveMe
  save('masterD_l5_oe1_bnd0','masterD_l5_oe1_bnd0');
end
masterD_l7_oe1_bnd0 = getDfromGridAveAsymp( './gridAveMSDdata/lPerc/edge1/bD0/l7/', 'aveGrid_*',plotMe,0 );
if saveMe
  save('masterD_l7_oe1_bnd0','masterD_l7_oe1_bnd0');
end
%%
% bnd1
masterD_l1_oe1_bnd1 = getDfromGridAveAsymp( './gridAveMSDdata/lPerc/edge0/bD1/l1/', 'aveGrid_*',plotMe,0 );
if saveMe
  save('masterD_l1_oe1_bnd1','masterD_l1_oe1_bnd1');
end

masterD_l3_oe1_bnd1 = getDfromGridAveAsymp( './gridAveMSDdata/lPerc/edge0/bD1/l3/', 'aveGrid_*',plotMe,0 );
if saveMe
  save('masterD_l3_oe1_bnd1','masterD_l3_oe1_bnd1');
end

masterD_l5_oe1_bnd1 = getDfromGridAveAsymp( './gridAveMSDdata/lPerc/edge0/bD1/l5/', 'aveGrid_*',plotMe,0 );
if saveMe
  save('masterD_l5_oe1_bnd1','masterD_l5_oe1_bnd1');
end

masterD_l7_oe1_bnd1 = getDfromGridAveAsymp( './gridAveMSDdata/lPerc/edge0/bD1/l7/', 'aveGrid_*',plotMe,0 );
if saveMe
  save('masterD_l7_oe1_bnd1','masterD_l7_oe1_bnd1');
end
