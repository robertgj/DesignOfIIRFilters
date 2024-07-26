% print_latex_test.m

graphics_toolkit("qt");

% dbstop print 

profile on
version

x=rand(1000,1);
plot(x);
tic;
print("x","-dpdflatex");
toc;
close;

profile off
profshow(5)

%{
% Compile the following TeX with pdflatex:

\pdfminorversion=7
\documentclass[a4paper,twoside,10pt,english]{report}
\usepackage{geometry}
\geometry{verbose,nomarginpar,tmargin=1.5cm,bmargin=1.5cm,lmargin=1.5cm,
rmargin=1.5cm,headheight=1cm,headsep=1cm,footskip=1cm}

\usepackage{amsfonts}
\usepackage{amsmath}
\usepackage{amssymb}
\usepackage{float}
\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}
\usepackage{lmodern}
\usepackage{graphicx}
\usepackage{xcolor}

\begin{document}

\begin{figure}
\centering
\scalebox{1}{\input{x}}
\end{figure}

\end{document}

%}
