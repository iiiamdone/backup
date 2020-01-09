#!/bin/bash
# Geoscripting 2020 
# Assignment 1
# Spatial map function
# Tests
# 04/06/2019

## Test Git use ##

declare -i GITERRORS=0

echo
echo "Checking Git use..."
echo

# Count number of commits
NUMCOM=$(git rev-list --all --count)
echo "Commit count: $NUMCOM"

# Check if sufficient
if [[ NUMCOM -lt 3 ]]
then
 echo "Number of commits not sufficient"
 GITERRORS+=1
else
 echo "Number of commits sufficient"
fi

# Count number of contributing users
NUMUS=$(git shortlog -s -n --all --no-merges | wc -l | sed 's/ //g')
echo
echo "Users contributed: $NUMUS"

# Check if sufficient
if [[ NUMUS -lt 2 ]]
then
 echo "Number of contributing users not sufficient"
 GITERRORS+=1
else 
 echo "Number of contributing users sufficient"
fi

echo
# Return status on Git use
if [[ GITERRORS -gt 0 ]]
then
 echo "Failed Git use with $GITERRORS errors: $NUMCOM/3 commits and $NUMUS/2 contributing users"
else 
 echo "Successful Git use : $NUMCOM/3 commits and $NUMUS/2 contributing users"
fi


## Test folder structure ##

declare -i STRUCERRORS=0

echo
echo "Checking folder structure..."
echo

# Check if main.R file is present in directory
MAINR=$(find . -maxdepth 1 -name "main.[rR]" | wc -l | sed 's/ //g')

if [[ MAINR -eq 0 ]]
then
 echo "No file named main.R found in main directory"
 STRUCERRORS+=1
else
 echo "main.R file found and placed correctly" 
fi


# Check if data file is present in directory
DATA=$(find . -maxdepth 1 -type d -name "[dD]ata" | wc -l | sed 's/ //g')

if [[ DATA -ne 0 ]]
then
 echo "Data folder should not be uploaded to Git repository, but created in your script"
 STRUCERRORS+=1
fi


# Check if required function is present in R directory
FUNC=$(find ./R/ -maxdepth 1 -name "*.[rR]" | wc -l | sed 's/ //g')

if [[ FUNC -eq 0 ]]
then
 echo "No scripts found in R folder, place your scripts with functions here"
 STRUCERRORS+=1
else
 echo "Scripts are present in R directory" 
fi


# Check if multiple R scripts present main directory
RFILES=$(find . -maxdepth 1 -name "*.[rR]" | wc -l | sed 's/ //g')

if [[ RFILES -gt 1 ]]
then
 echo "Multiple R scripts in main directory. Only main.R should be placed in main directory, move other scripts to R folder"
 STRUCERRORS+=1
else
 echo "No scripts other than main.R found in main directory"
fi 


echo
# Return status on Git use
if [[ STRUCERRORS -gt 0 ]]
then
 echo "Failed project structure with $STRUCERRORS errors"
else 
 echo "Successful project structure"
fi
echo


# Set exit status
let EXSTAT=$GITERRORS+$STRUCERRORS

# Exit with exit status
exit $EXSTAT



