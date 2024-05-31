% test_common.m
% Copyright (C) 2017-2024 Robert G. Jenssen

% Normally these would be in .octaverc or ~/.octaverc

clear all

more off
page_screen_output(false);
suppress_verbose_help_message(true);
output_precision(5)
format compact

pkg load signal;

% Initialise graphics
try
  graphics_toolkit("qt");
catch
  graphics_toolkit("gnuplot");
end_try_catch

set(0,"defaultaxestitlefontweight","normal");

% Try to place Octave GUI figures on-screen for XWindows. Octave sets the
% default figure position and size in file libinterp/corefcn/graphics.cc
% in function default_figure_position().
if getenv("OCTAVE_ENABLE_PLOT_TO_SCREEN")
  pos=get(0,"defaultfigureposition");
  set(0,"defaultfigureposition",[1000,1000,pos(3),pos(4)]);
  set(0,'DefaultFigureVisible','on');
else
  % Disable plotting to the screen. It captures the screen focus.
  set(0,'DefaultFigureVisible','off');
endif

if getenv("OCTAVE_ENABLE_MONOCHROME")
  % For monochrome printing
  set(0,"defaultaxescolororder",zeros(size(get(0,"defaultaxescolororder"))));
endif

close all force;

% Make warnings into errors
warning("error","Octave:assign-as-truth-value");
warning("error","Octave:associativity-change");
warning("error","Octave:broadcast");
warning("error","Octave:deprecated-keyword");
warning("error","Octave:divide-by-zero");
warning("error","Octave:function-name-clash");
warning("error","Octave:shadowed-function");
warning("error","Octave:neg-dim-as-zero");
warning("error","Octave:nonconformant-args");
warning("error","Octave:noninteger-range-as-index");
warning("error","Octave:possible-matlab-short-circuit-operator");
warning("error","Octave:precedence-change");
warning("error","Octave:singular-matrix");
warning("error","Octave:nearly-singular-matrix");
warning("error","Octave:undefined-return-values");

% Disable some noisy warnings (note patches to octave source files)
warning("off","Octave:data-file-in-path");
warning("off","Octave:LaTeX:internal-error");
warning("off","signal:delayz-singularity");
warning("off","signal:grpdelay-singularity");
if strcmp("9.1.0-robj",OCTAVE_VERSION)
  % See scripts/plot/util/private/__gnuplot_draw_axes__.m
  warning("off","Octave:latex-markup-not-supported-for-tick-marks");
  % See scripts/miscellaneous/delete.m
  warning("off","Octave:delete:no-such-file");
  % See libinterp/corefcn/load-path.cc
  warning("off","Octave:load-path:update-failed");
  warning("off","Octave:load-path:dir-info:update-failed");
endif

