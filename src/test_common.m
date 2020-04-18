% test_common.m
% Copyright (C) 2017-2019 Robert G. Jenssen

% Normally these would be in .octaverc or ~/.octaverc

clear all
more off
pkg load signal optim;
graphics_toolkit("gnuplot");
if getenv("OCTAVE_ENABLE_PLOT_TO_SCREEN")
  % Enabling plotting to the screen causes difficulties when building the
  % entire project: the plots capture the screen focus.
  set(0,'DefaultFigureVisible','on');
  % Choose the appropriate linewidth for the svg file format.
  % See :https://savannah.gnu.org/bugs/?43552
  set(0,"defaultlinelinewidth",4);
else
  % Disable plotting to the screen.
  set(0,'DefaultFigureVisible','off');
  % Choose the appropriate linewidth for the pdf file format.
  set(0,"defaultlinelinewidth",8);
endif
% Comment the following line for octave-4.0.3
set(0,"defaultaxestitlefontweight","normal");
% For monochrome printing
if getenv("OCTAVE_ENABLE_MONOCHROME")
  set(0,"defaultaxescolororder",zeros(size(get(0,"defaultaxescolororder"))));
endif
clf
close

page_screen_output(false);
suppress_verbose_help_message(true);
output_precision(5)
format short
format compact

warning("error","Octave:assign-as-truth-value");
warning("error","Octave:associativity-change");
warning("error","Octave:broadcast");
warning("error","Octave:deprecated-keyword");
warning("error","Octave:divide-by-zero");
warning("error","Octave:function-name-clash");
warning("error","Octave:nearly-singular-matrix");
warning("error","Octave:neg-dim-as-zero");
warning("error","Octave:nonconformant-args");
warning("error","Octave:noninteger-range-as-index");
warning("error","Octave:possible-matlab-short-circuit-operator");
warning("error","Octave:precedence-change");
warning("error","Octave:singular-matrix");
warning("error","Octave:undefined-return-values");

% Disable some noisy warnings
warning ("off","signal:grpdelay-singularity");
% See octave-5.2.0/scripts/plot/util/private/__gnuplot_draw_axes__.m:2257
warning ("off","Octave:latex-markup-not-supported-for-tick-marks");
% See octave-5.2.0/scripts/miscellaneous/delete.m
warning ("off","Octave:delete-no-such-file");

% Add third party optimisers to the path
name_strs={"SeDuMi_1_3","SparsePOP302"};
mpath=mfilename("fullpath");
mpath=mpath(1:strchr(mpath,filesep,1,'last'));
for k=1:length(name_strs)
  mname=strcat(mpath,name_strs{k});
  if exist(mname) == 7
    addpath(mname);
  endif
endfor
