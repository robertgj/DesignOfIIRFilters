% test_common.m
% Copyright (C) 2017-2019 Robert G. Jenssen

% Normally these would be in .octaverc or ~/.octaverc

clear all
more off
pkg load signal optim;
graphics_toolkit("gnuplot");
% Change the linewidth for each file format.
% See :https://savannah.gnu.org/bugs/?43552
set(0,"defaultlinelinewidth",8);
% Comment the following line for octave-4.0.3
set(0,"defaultaxestitlefontweight","normal");
% The following set command disables plotting to the screen.
set(0,'DefaultFigureVisible','off');
warning("Plotting to the screen is disabled!");
% Uncomment this for monochrome printing
% set(0,"defaultaxescolororder",zeros(size(get(0,"defaultaxescolororder"))));
clf
close

page_screen_output(false);
suppress_verbose_help_message(true);

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

% See octave-5.1.0/scripts/plot/util/private/__gnuplot_draw_axes__.m:2257
warning ("off","Octave:latex-markup-not-supported-for-tick-marks");

name_strs={"SeDuMi_1_3","SparsePOP302"};
mpath=mfilename("fullpath");
mpath=mpath(1:strchr(mpath,filesep,1,'last'));
for k=1:length(name_strs)
  mname=strcat(mpath,name_strs{k});
  if exist(mname) == 7
    addpath(mname);
  endif
endfor
