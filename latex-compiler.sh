#!/bin/bash
# This script work by searching "begin{document}" function in tex main file
# in current directory, if it doesn't find the main file it will go to
# previous directory and begin to search again.

# no color
nc='\033[0m'
# light green
green='\033[1;32m'
# yellow
yellow='\033[1;33m'
# light red
red='\033[1;31m'

function find_file()
{
    grep -R -i --include \*.tex begin{document} | grep tex | wc -l
}

function get_tex_file_name()
{
    echo $(grep -R -i --include \*.tex begin{document} | grep tex | cut -f 1 -d ':')
}

function get_file_name()
{
    echo $(grep -R -i --include \*.tex begin{document} | grep tex | cut -f 1 -d ':' | cut -f 1 -d '.')
}

function compile()
{
    xelatex -synctex=1 -interaction=nonstopmode $( get_tex_file_name )
    biber $( get_file_name )
    xelatex -synctex=1 -interaction=nonstopmode $( get_tex_file_name )
    exstat=$?
    if [ ${exstat} -eq 0 ]; then
        echo
        printf "${yellow}main tex file $( get_tex_file_name ) found at $PWD\n"
        printf "${green}compiling $( get_tex_file_name ) success\n${nc}"
    else
        echo
        printf "${yellow}main tex file $( get_tex_file_name ) found at $PWD\n"
        printf "${red}compiling $( get_tex_file_name ) error${nc}\n"
        read -n 1 -s -r -p "Press any key to continue"
    fi
}

cd $1
if [ $( find_file ) -ne 0 ]; then
    compile
else
    cd ..
    if [ $( find_file ) -ne 0 ]; then
        compile
    else
        cd ..
        if [ $( find_file ) -ne 0 ]; then
            compile
        else
            echo FILE NOT FOUND
        fi
    fi
fi
