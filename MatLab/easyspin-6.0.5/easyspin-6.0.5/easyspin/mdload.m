%  mdload     Load data generated by molecular dynamics simulations
%
%   MD = mdload(TrajFile,TopFile);
%   MD = mdload(TrajFile,TopFile,Info);
%   MD = mdload(TrajFile,TopFile,Info,Opt);
%
%   Input:
%     TrajFile  Name of trajectory output file from the MD simulation.
%               Supported formats are identified via the extension
%               in TrajFile and TopFile. Extensions:
%
%                 .DCD and .PSF:   NAMD, X-PLOR, CHARMM
%                 .TRR and .GRO:   Gromacs
%
%     TopFile   Name of topology input file used for the MD simulation.
%
%     Info      structure array containing the following fields
%
%         .SegName    character array
%               Name of segment in the topology file assigned to the
%               spin-labeled protein. If empty, the first segment name
%               is chosen. This field is ignored for .TRR/.GRO, since
%               those do not contain segment names.
%
%         .ResName    character array
%               Name of residue assigned to spin label side 
%               chain. If not give, 'CYR1' is assumed, which is
%               the default used by CHARMM-GUI for R1.
%
%         .LabelName  spin label name, 'R1' or 'TOAC'
%               If not given, it will be inferred from ResName
%
%         .AtomNames  structure array (optional)
%               Contains the atom names used in the structure file to refer to
%               the following atoms in the nitroxide spin label molecule model.
%               The defaults for R1 and TOAC are:
%
%                      R1:
%                                              ON (ONname)
%                                              |
%                                              NN (NNname)
%                                            /   \
%                                  (C1name) C1    C2 (C2name)
%                                           |     |
%                                 (C1Rname) C1R = C2R (C2Rname)
%                                           |
%                                 (C1Lname) C1L
%                                           |
%                                 (S1Lname) S1L
%                                          /
%                                (SGname) SG
%                                         |
%                                (CBname) CB
%                                         |
%                             (Nname) N - CA (CAname)
%
%                      TOAC:
%                                         ON (ONname)
%                                         |
%                                         NN (NNname)
%                                        /   \
%                             (CGRname) CGR  CGS (CGSname)
%                                       |    |
%                             (CBRname) CBR  CBS (CBSname)
%                                        \  /
%                             (Nname) N - CA (CAname)
%
%
%     Opt    structure array containing the following fields
%
%        .Verbosity    0: no display
%                      1: (default) show info
%
%        .keepProtC A  0: (default) delete protein alpha carbon coordinates
%                      1: keep them
%
%   Output:
%     MD        structure array containing the following fields:
%
%       .nSteps  total number of steps in trajectory
%
%       .dt      size of time step (in s)
%
%       .FrameTraj   numeric array, size = (3,3,nTraj,nSteps)
%                    xyz coordinates of coordinate frame axis
%                    vectors, x-axis corresponds to
%                    FrameTraj(:,1,nTraj,:), y-axis corresponds to
%                    FrameTraj(:,2,nTraj,:), etc.
%
%       .FrameTrajwrtProt   numeric array, size = (3,3,nTraj,nSteps)
%                           same as FrameTraj, but with global
%                           rotational diffusion of protein removed
%
%       .RProtDiff   numeric array, size = (3,3,nTraj,nSteps)
%                    trajectories of protein global rotational
%                    diffusion represented by rotation matrices
%
%       .dihedrals   numeric array, size = (nDihedrals,nTraj,nSteps)
%                    dihedral angles of spin label side chain;
%                    nDihedrals=5 for R1, nDihedrals=2 for TOAC
%
